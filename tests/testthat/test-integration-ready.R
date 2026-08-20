# Integration tests for real API testing
# These tests run when an API key is available via yt_set_key() or YOUTUBE_KEY env var
# Helper to check if API key is available
skip_if_no_api_key <- function() {
  api_key <- suppressMessages(yt_get_key())
  if (is.null(api_key)) {
    testthat::skip("No YouTube API key found. Set one with yt_set_key()")
  }
}

# ==============================================================================
# Channel Functions
# ==============================================================================

test_that("get_channel_details works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_channel_details(channel_ids = "UC_x5XG1OV2P6uZZ5FSM9Ttw", auth = "key")

  expect_true(!is.null(result))
})

test_that("get_channel_details resolves legacy usernames", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_channel_details(
    usernames = "GoogleDevelopers",
    part = "id",
    auth = "key"
  )

  expect_true(nrow(result) > 0)
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

  result <- get_video_details(video_ids = "dQw4w9WgXcQ", auth = "key")

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

test_that("get_video_stats returns a data frame", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_video_stats(video_ids = "dQw4w9WgXcQ", auth = "key")

  expect_s3_class(result, "data.frame")
  expect_true("view_count" %in% names(result))
})

test_that("get_video_stats includes content details", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- get_video_stats(
    video_ids = "dQw4w9WgXcQ",
    include_content_details = TRUE,
    auth = "key"
  )

  expect_s3_class(result, "data.frame")
  expect_true("duration" %in% names(result))
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

test_that("list_playlist_items works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_playlist_items(
    playlist_id = "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf",
    max_results = 5,
    auth = "key"
  )

  expect_true(!is.null(result))
})

test_that("list_playlists works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_playlists(
    channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw",
    max_results = 3,
    auth = "key"
  )

  expect_true(!is.null(result))
})

# ==============================================================================
# Comment Functions
# ==============================================================================

test_that("list_comment_threads works", {
  skip_on_cran()
  skip_if_no_api_key()

  result <- list_comment_threads(
    video_id = "dQw4w9WgXcQ",
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
    channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw",
    max_results = 3,
    auth = "key"
  )

  expect_true(!is.null(result))
})

# ==============================================================================
# Caption Functions
# ==============================================================================

test_that("list_captions works", {
  skip_on_cran()
  token <- yt_token()
  if (is.null(token) || !is.function(token$sign)) {
    skip("No usable YouTube OAuth token available")
  }

  result <- list_captions(video_id = "dQw4w9WgXcQ")

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
