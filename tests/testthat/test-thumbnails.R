test_that("set_video_thumbnail functions correctly", {
  skip_on_cran()

  with_mocked_bindings(
    yt_check_token = function() TRUE,
    track_quota_usage = function(endpoint, method) {
      expect_equal(c(endpoint, method), c("thumbnails", "set"))
      invisible(NULL)
    },
    tuber_check = function(req) invisible(TRUE),
    content = function(req) {
      list(
        items = list(
          list(default = list(url = "https://example.com/thumb.jpg"))
        )
      )
    },
    {
      with_mocked_bindings(
        POST = function(url, ...) {
          expect_true(grepl("thumbnails/set", url))
          expect_equal(list(...)$query$uploadType, "media")
          res <- list(status_code = 200, request = list(), url = "https://example.com/mock")
          class(res) <- "response"
          res
        },
        .package = "httr",
        {
          tmp <- tempfile(fileext = ".jpg")
          writeBin(as.raw(1:10), tmp)

          result <- set_video_thumbnail(video_id = "test_vid", file = tmp)

          expect_true(is.list(result))
          expect_equal(result$content$items[[1]]$default$url, "https://example.com/thumb.jpg")

          unlink(tmp)
        }
      )
    }
  )
})

test_that("insert_channel_banner functions correctly", {
  skip_on_cran()

  with_mocked_bindings(
    yt_check_token = function() TRUE,
    track_quota_usage = function(endpoint, method) {
      expect_equal(c(endpoint, method), c("channelBanners", "insert"))
      invisible(NULL)
    },
    tuber_check = function(req) invisible(TRUE),
    content = function(req) {
      list(
        kind = "youtube#channelBannerResource",
        url = "https://example.com/banner.jpg"
      )
    },
    {
      with_mocked_bindings(
        POST = function(url, ...) {
          expect_true(grepl("channelBanners/insert", url))
          expect_equal(list(...)$query$uploadType, "media")
          res <- list(status_code = 200, request = list(), url = "https://example.com/mock")
          class(res) <- "response"
          res
        },
        .package = "httr",
        {
          tmp <- tempfile(fileext = ".jpg")
          writeBin(as.raw(1:10), tmp)

          result <- insert_channel_banner(file = tmp)

          expect_true(is.list(result))
          expect_equal(result$content$url, "https://example.com/banner.jpg")

          unlink(tmp)
        }
      )
    }
  )
})
