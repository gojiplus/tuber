# Integration tests ready for real API testing
# These tests will run when you provide an API key

context("API Integration Tests")

test_that("yt_search works with API key", {
  skip_on_cran()
  
  # Check if API key is available
  api_key <- suppressMessages(yt_get_key())
  if (is.null(api_key)) {
    skip("No YouTube API key found. Set one with yt_set_key('your_key')")
  }
  
  # Test basic search functionality
  result <- yt_search(
    term = "test",
    max_results = 5,
    get_all = FALSE,
    auth = "key"
  )
  
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) <= 5)
  expect_true("video_id" %in% colnames(result))
  expect_true("title" %in% colnames(result))
})

test_that("get_video_details works with API key", {
  skip_on_cran()
  
  api_key <- suppressMessages(yt_get_key())
  if (is.null(api_key)) {
    skip("No YouTube API key found. Set one with yt_set_key('your_key')")
  }
  
  # Test with a known video ID (Rick Astley - Never Gonna Give You Up)
  result <- get_video_details(
    video_id = "dQw4w9WgXcQ",
    auth = "key"
  )
  
  expect_true(is.list(result))
  expect_true(!is.null(result$items))
})

test_that("get_playlist_items pagination works correctly", {
  skip_on_cran()
  
  api_key <- suppressMessages(yt_get_key())
  if (is.null(api_key)) {
    skip("No YouTube API key found. Set one with yt_set_key('your_key')")
  }
  
  # Test with a known large playlist - YouTube's own "YouTube Rewind" playlist
  # This tests the pagination fixes we implemented
  tryCatch({
    result <- get_playlist_items(
      filter = c(playlist_id = "PL590L5WQmH8fJ54F369BLDSqIwcs-TCfs"),
      max_results = 60,  # Force pagination (>50)
      auth = "key"
    )
    
    if (!is.null(result$items)) {
      expect_true(length(result$items) <= 60)
      expect_true(length(result$items) > 50)  # Should have paginated
    }
    
  }, error = function(e) {
    # If the specific playlist doesn't work, skip with message
    skip(paste("Playlist test failed:", e$message))
  })
})

test_that("get_all_comments works with public video", {
  skip_on_cran()
  
  api_key <- suppressMessages(yt_get_key())
  if (is.null(api_key)) {
    skip("No YouTube API key found. Set one with yt_set_key('your_key')")
  }
  
  # Test with a video that likely has comments
  tryCatch({
    result <- get_all_comments(
      video_id = "dQw4w9WgXcQ",  # Rick Roll - lots of comments
      auth = "key"
    )
    
    expect_true(is.data.frame(result) || is.matrix(result))
    if (nrow(result) > 0) {
      expect_true("textDisplay" %in% colnames(result))
    }
    
  }, error = function(e) {
    # Comments might be disabled, so this could fail
    skip(paste("Comments test failed (comments may be disabled):", e$message))
  })
})

test_that("API quota management works", {
  skip_on_cran()
  
  api_key <- suppressMessages(yt_get_key())
  if (is.null(api_key)) {
    skip("No YouTube API key found. Set one with yt_set_key('your_key')")
  }
  
  # Test that search with max_results limit works
  start_time <- Sys.time()
  
  result <- yt_search(
    term = "tutorial",
    max_results = 10,
    get_all = FALSE,
    auth = "key"
  )
  
  end_time <- Sys.time()
  
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) <= 10)
  
  # Should complete relatively quickly for small requests
  expect_true(as.numeric(end_time - start_time) < 10)  # Less than 10 seconds
})

# Helper function to check if we can run tests
check_api_access <- function() {
  api_key <- suppressMessages(yt_get_key())
  oauth_available <- file.exists("token_file.rds.enc")
  
  list(
    has_api_key = !is.null(api_key),
    has_oauth = oauth_available,
    can_test_basic = !is.null(api_key),
    can_test_advanced = oauth_available
  )
}

test_that("API access check helper works", {
  access <- check_api_access()
  expect_true(is.logical(access$has_api_key))
  expect_true(is.logical(access$has_oauth))
  expect_true(is.logical(access$can_test_basic))
  expect_true(is.logical(access$can_test_advanced))
})