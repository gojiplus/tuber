# Basic functionality tests that don't require API access

context("Basic Package Functionality")

test_that("Core functions exist", {
  expect_true(exists("yt_search"))
  expect_true(exists("get_video_details"))  
  expect_true(exists("get_all_comments"))
  expect_true(exists("get_playlist_items"))
  expect_true(exists("list_channel_videos"))
})

test_that("Parameter validation works", {
  expect_error(get_all_comments(video_id = NULL), "video_id must be")
  expect_error(get_all_comments(video_id = c("a", "b")), "video_id must be")
  expect_error(yt_search(term = NULL), "Must specify a search term")
})

test_that("Quota management functions work", {
  expect_true(exists("yt_get_quota_usage"))
  expect_true(exists("yt_set_quota_limit"))
  expect_true(exists("yt_reset_quota"))
  
  # Test quota usage function
  quota_info <- yt_get_quota_usage()
  expect_true(is.list(quota_info))
  expect_true("quota_used" %in% names(quota_info))
  expect_true("quota_limit" %in% names(quota_info))
  
  # Test quota limit setting
  original_limit <- quota_info$quota_limit
  yt_set_quota_limit(15000)
  expect_equal(yt_get_quota_usage()$quota_limit, 15000)
  
  # Reset to original
  yt_set_quota_limit(original_limit)
})

test_that("Unicode utilities work", {
  expect_true(exists("safe_utf8"))
  expect_true(exists("clean_youtube_text"))
  
  # Test basic UTF-8 handling
  test_text <- "Hello, world! 🌍"
  result <- safe_utf8(test_text)
  expect_equal(result, test_text)
  
  # Test text cleaning
  html_text <- "<b>Bold text</b> &amp; entities"
  cleaned <- clean_youtube_text(html_text)
  expect_equal(cleaned, "Bold text & entities")
})

test_that("Authentication functions exist", {
  expect_true(exists("yt_oauth"))
  expect_true(exists("yt_token"))
  expect_true(exists("yt_authorized"))
  expect_true(exists("yt_get_key"))
  expect_true(exists("yt_set_key"))
})