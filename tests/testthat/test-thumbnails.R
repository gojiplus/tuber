test_that("set_video_thumbnail functions correctly", {
  seen <- new.env(parent = emptyenv())

  with_mocked_bindings(
    yt_check_token = function() TRUE,
    yt_access_token = function() "fake-token",
    track_quota_usage = function(endpoint, method) {
      expect_equal(c(endpoint, method), c("thumbnails", "set"))
      invisible(NULL)
    },
    {
      httr2::local_mocked_responses(function(req) {
        seen$req <- req
        httr2::response_json(
          status_code = 200L,
          body = list(
            items = list(
              list(default = list(url = "https://example.com/thumb.jpg"))
            )
          )
        )
      })

      tmp <- withr::local_tempfile(fileext = ".jpg")
      writeBin(as.raw(1:10), tmp)

      result <- set_video_thumbnail(video_id = "test_vid", file = tmp)

      url <- httr2::url_parse(seen$req$url)
      expect_equal(url$path, "/upload/youtube/v3/thumbnails/set")
      expect_equal(url$query$uploadType, "media")
      expect_equal(url$query$videoId, "test_vid")
      expect_equal(seen$req$method, "POST")
      expect_equal(seen$req$body$data, tmp)
      expect_equal(seen$req$body$content_type, "image/jpeg")

      expect_true(is.list(result))
      expect_equal(result$content$items[[1]]$default$url, "https://example.com/thumb.jpg")
    }
  )
})

test_that("insert_channel_banner functions correctly", {
  seen <- new.env(parent = emptyenv())

  with_mocked_bindings(
    yt_check_token = function() TRUE,
    yt_access_token = function() "fake-token",
    track_quota_usage = function(endpoint, method) {
      expect_equal(c(endpoint, method), c("channelBanners", "insert"))
      invisible(NULL)
    },
    {
      httr2::local_mocked_responses(function(req) {
        seen$req <- req
        httr2::response_json(
          status_code = 200L,
          body = list(
            kind = "youtube#channelBannerResource",
            url = "https://example.com/banner.jpg"
          )
        )
      })

      tmp <- withr::local_tempfile(fileext = ".jpg")
      writeBin(as.raw(1:10), tmp)

      result <- insert_channel_banner(file = tmp)

      url <- httr2::url_parse(seen$req$url)
      expect_equal(url$path, "/upload/youtube/v3/channelBanners/insert")
      expect_equal(url$query$uploadType, "media")
      expect_equal(seen$req$method, "POST")

      expect_true(is.list(result))
      expect_equal(result$content$url, "https://example.com/banner.jpg")
    }
  )
})
