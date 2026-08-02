# Offline tests that assert on the request tuber assembles, and on the
# post-processing of a canned response. The HTTP layer is mocked, so these
# never touch the network.

# Build a tuber_GET stand-in that records every (path, query) it is handed and
# returns a canned response. `$reqs` holds the captured requests afterwards.
new_capture <- function(response) {
  captured <- new.env(parent = emptyenv())
  captured$reqs <- list()
  captured$fn <- function(path, query, ...) {
    captured$reqs[[length(captured$reqs) + 1L]] <- list(path = path, query = query)
    response
  }
  captured
}

# A videoCategories/guideCategories style response with `n` items.
cat_items <- function(n) {
  list(items = lapply(seq_len(n), function(i) {
    list(etag = "etag1", id = as.character(i),
         snippet = list(channelId = "UCchannel",
                        title = paste("Category", i),
                        assignable = TRUE))
  }))
}

test_that("every query component tuber builds is named", {
  # httr and httr2 both reject a query list containing an unnamed element, so
  # an unnamed component means the request can never be sent.
  expect_query_named <- function(reqs) {
    for (r in reqs) {
      nms <- names(r$query)
      expect_false(is.null(nms))
      expect_true(all(nzchar(nms)),
                  info = paste("unnamed query component for path", r$path))
    }
  }

  cap <- new_capture(cat_items(2))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  try(list_videocats(c(region_code = "JP")), silent = TRUE)
  try(list_guidecats(c(region_code = "JP")), silent = TRUE)
  expect_gt(length(cap$reqs), 0)
  expect_query_named(cap$reqs)
})

test_that("list_videocats sends regionCode and returns a data.frame", {
  cap <- new_capture(cat_items(2))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  res <- list_videocats(c(region_code = "JP"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2)
  expect_true(all(res$region_code == "JP"))
  expect_length(cap$reqs, 1)
  expect_equal(cap$reqs[[1]]$path, "videoCategories")
  expect_equal(cap$reqs[[1]]$query$regionCode, "JP")
})

test_that("list_videocats with a category_id filter sends id", {
  cap <- new_capture(cat_items(1))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  list_videocats(c(category_id = "10"))
  expect_equal(cap$reqs[[1]]$query$id, "10")
})

test_that("list_guidecats sends regionCode and hl, and returns a data.frame", {
  cap <- new_capture(cat_items(2))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  res <- list_guidecats(c(region_code = "JP"), hl = "ja")
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2)
  expect_length(cap$reqs, 1)
  expect_equal(cap$reqs[[1]]$path, "guideCategories")
  expect_equal(cap$reqs[[1]]$query$regionCode, "JP")
  expect_equal(cap$reqs[[1]]$query$hl, "ja")
})

test_that("list_guidecats returns an empty data.frame when there are no items", {
  cap <- new_capture(cat_items(0))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  res <- list_guidecats(c(region_code = "ZZ"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0)
})

test_that("get_comments forwards page_token as pageToken", {
  # comments.list documents a pageToken parameter; without it, paging through
  # replies with a parent_id filter always returns the first page.
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  suppressWarnings(get_comments(filter = c(parent_id = "P1"), page_token = "TOKEN123"))
  expect_equal(cap$reqs[[1]]$query$pageToken, "TOKEN123")
})

test_that("get_comments omits pageToken when none is given", {
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  suppressWarnings(get_comments(filter = c(parent_id = "P1")))
  expect_null(cap$reqs[[1]]$query$pageToken)
})

test_that("list_regions forwards hl", {
  # i18nRegions.list documents an hl parameter; the sibling list_langs() sends it.
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  list_regions(hl = "fr")
  expect_equal(cap$reqs[[1]]$path, "i18nRegions")
  expect_equal(cap$reqs[[1]]$query$hl, "fr")
})

test_that("list_abuse_report_reasons forwards hl", {
  # videoAbuseReportReasons.list documents an hl parameter.
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  list_abuse_report_reasons(hl = "fr")
  expect_equal(cap$reqs[[1]]$path, "videoAbuseReportReasons")
  expect_equal(cap$reqs[[1]]$query$hl, "fr")
})

test_that("get_live_streams sends the status filter as broadcastStatus", {
  # liveBroadcasts.list has no eventType parameter; the documented filter for
  # broadcast state is broadcastStatus.
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  get_live_streams(stream_id = "S1", status = "completed")
  expect_equal(cap$reqs[[1]]$path, "liveBroadcasts")
  expect_equal(cap$reqs[[1]]$query$broadcastStatus, "completed")
  expect_null(cap$reqs[[1]]$query$eventType)
})
