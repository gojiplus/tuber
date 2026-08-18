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
  try(list_video_categories(region_code = "JP"), silent = TRUE)
  expect_gt(length(cap$reqs), 0)
  expect_query_named(cap$reqs)
})

test_that("list_video_categories sends regionCode and returns a data.frame", {
  cap <- new_capture(cat_items(2))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  res <- list_video_categories(region_code = "JP")
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2)
  expect_true(all(res$region_code == "JP"))
  expect_length(cap$reqs, 1)
  expect_equal(cap$reqs[[1]]$path, "videoCategories")
  expect_equal(cap$reqs[[1]]$query$regionCode, "JP")
})

test_that("list_video_categories with category_ids sends id", {
  cap <- new_capture(cat_items(1))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  list_video_categories(category_ids = "10")
  expect_equal(cap$reqs[[1]]$query$id, "10")
})

test_that("list_comments forwards page_token as pageToken", {
  # comments.list documents a pageToken parameter; without it, paging through
  # replies with a parent_id filter always returns the first page.
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  suppressWarnings(list_comments(parent_id = "P1", page_token = "TOKEN123"))
  expect_equal(cap$reqs[[1]]$query$pageToken, "TOKEN123")
})

test_that("list_comments omits pageToken when none is given", {
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  suppressWarnings(list_comments(parent_id = "P1"))
  expect_null(cap$reqs[[1]]$query$pageToken)
})

test_that("list_regions forwards language as hl", {
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  list_regions(language = "fr")
  expect_equal(cap$reqs[[1]]$path, "i18nRegions")
  expect_equal(cap$reqs[[1]]$query$hl, "fr")
})

test_that("list_abuse_report_reasons forwards language as hl", {
  # videoAbuseReportReasons.list documents an hl parameter.
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
  list_abuse_report_reasons(language = "fr")
  expect_equal(cap$reqs[[1]]$path, "videoAbuseReportReasons")
  expect_equal(cap$reqs[[1]]$query$hl, "fr")
})

test_that("list_live_broadcasts sends exactly one liveBroadcasts.list filter", {
  # liveBroadcasts.list accepts exactly one of broadcastStatus, id or mine, has
  # no eventType, and has no channelId at all. The first version of this test
  # asserted the invalid id + broadcastStatus pair, which an independent review
  # caught.
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")

  list_live_broadcasts(status = "completed")
  expect_equal(cap$reqs[[1]]$path, "liveBroadcasts")
  expect_equal(cap$reqs[[1]]$query$broadcastStatus, "completed")
  expect_null(cap$reqs[[1]]$query$eventType)
  expect_null(cap$reqs[[1]]$query$id)

  list_live_broadcasts(broadcast_ids = "S1")
  expect_equal(cap$reqs[[2]]$query$id, "S1")
  expect_null(cap$reqs[[2]]$query$broadcastStatus)

  list_live_broadcasts(mine = TRUE)
  expect_equal(cap$reqs[[3]]$query$mine, "true")
})

test_that("list_live_broadcasts refuses combinations the API does not accept", {
  expect_error(
    list_live_broadcasts(broadcast_ids = "S1", status = "completed"),
    class = "tuber_conflicting_parameters"
  )
  expect_error(list_live_broadcasts(), class = "tuber_missing_required_parameter")
})

test_that("list_live_chat_messages respects API page and image limits", {
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")

  list_live_chat_messages(
    live_chat_id = "chat",
    max_results = 25,
    profile_image_size = 720
  )
  expect_equal(cap$reqs[[1]]$query$maxResults, 200)
  expect_equal(cap$reqs[[1]]$query$profileImageSize, 720)
  expect_error(
    list_live_chat_messages("chat", profile_image_size = 721),
    "profile_image_size"
  )
})

test_that("list_channel_members uses current member filters", {
  cap <- new_capture(list(items = list()))
  local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")

  list_channel_members(
    mode = "updates",
    filter_by_member_channel_ids = c("UC1", "UC2")
  )
  expect_equal(cap$reqs[[1]]$query$mode, "updates")
  expect_equal(cap$reqs[[1]]$query$filterByMemberChannelId, "UC1,UC2")
  expect_error(list_channel_members(mode = "newest"), "mode")
})
