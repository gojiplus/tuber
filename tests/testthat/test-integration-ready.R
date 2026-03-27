# Integration tests for real API testing
# These tests run when an API key is available via yt_set_key() or YOUTUBE_KEY env var

context("API Integration Tests")

# Helper to check if API key is available
skip_if_no_api_key <- function() {
  api_key <- suppressMessages(yt_get_key())
  if (is.null(api_key)) {
    skip("No YouTube API key found. Set one with yt_set_key('your_key')")
  }
}

# ==============================================================================
# Channel Functions
# ==============================================================================

test_that("get_channel_stats works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_channel_stats(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw", auth = "key")

  expect_true(!is.null(result))
})

test_that("list_channel_resources works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_channel_resources(
    filter = c(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw"),
    part = "snippet",
    simplify = FALSE,
    auth = "key"
  )

  expect_true(length(result$items) > 0)
})

test_that("list_channel_videos works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_channel_videos(
    channel_id = "UCxOhDvtaoXDAB336AolWs3A",
    max_results = 5,
    auth = "key"
  )

  expect_true(!is.null(result))
})

test_that("get_all_channel_video_stats works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_all_channel_video_stats(
    channel_id = "UCxOhDvtaoXDAB336AolWs3A",
    auth = "key"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("view_count" %in% names(result))
  expect_true("like_count" %in% names(result))
  expect_true(!is.na(result$view_count[1]))
})

# ==============================================================================
# Video Functions
# ==============================================================================

test_that("get_video_details (single) works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_video_details(video_id = "dQw4w9WgXcQ", auth = "key")

  expect_true(is.list(result))
  expect_true(length(result$items) > 0)
})

test_that("get_video_details (simplify) works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_video_details(
    video_id = "dQw4w9WgXcQ",
    simplify = TRUE,
    auth = "key"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) == 1)
})

test_that("get_video_details (batch) works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_video_details(
    video_ids = c("dQw4w9WgXcQ", "jNQXAC9IVRw"),
    simplify = TRUE,
    auth = "key"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) == 2)
})

test_that("get_stats works with simplify=FALSE", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_stats(video_ids = "dQw4w9WgXcQ", simplify = FALSE, auth = "key")

  expect_true(!is.null(result$viewCount))
})

test_that("get_stats works with simplify=TRUE", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_stats(video_ids = "dQw4w9WgXcQ", simplify = TRUE, auth = "key")

  expect_s3_class(result, "data.frame")
})

# ==============================================================================
# Search Functions
# ==============================================================================

test_that("yt_search works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- yt_search(term = "test", max_results = 5, auth = "key")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) <= 5)
  expect_true("video_id" %in% names(result))
})

# ==============================================================================
# Playlist Functions
# ==============================================================================

test_that("get_playlist_items works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_playlist_items(
    filter = c(playlist_id = "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf"),
    max_results = 5,
    auth = "key"
  )

  expect_true(!is.null(result))
})

test_that("get_playlists works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_playlists(
    filter = c(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw"),
    max_results = 3,
    auth = "key"
  )

  expect_true(!is.null(result))
})

# ==============================================================================
# Comment Functions
# ==============================================================================

test_that("get_comment_threads works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_comment_threads(
    filter = c(video_id = "dQw4w9WgXcQ"),
    max_results = 5,
    auth = "key"
  )

  expect_true(!is.null(result))
})

test_that("get_all_comments respects max_results", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_all_comments(
    video_id = "dQw4w9WgXcQ",
    max_results = 10,
    auth = "key"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) <= 10)
})

# ==============================================================================
# Activity Functions
# ==============================================================================

test_that("list_channel_activities works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_channel_activities(
    filter = c(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw"),
    max_results = 3,
    auth = "key"
  )

  expect_true(!is.null(result))
})

# ==============================================================================
# Caption Functions
# ==============================================================================

test_that("list_caption_tracks works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_caption_tracks(video_id = "dQw4w9WgXcQ", auth = "key")

  expect_s3_class(result, "data.frame")
})

# ==============================================================================
# Channel Section Functions
# ==============================================================================

test_that("list_channel_sections works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_channel_sections(
    filter = c(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw"),
    auth = "key"
  )

  expect_true(!is.null(result))
})

# ==============================================================================
# Deprecated Functions
# ==============================================================================

test_that("get_related_videos is defunct", {
  expect_error(
    get_related_videos(video_id = "dQw4w9WgXcQ"),
    "defunct"
  )
})
