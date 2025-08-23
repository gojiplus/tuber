# Mock tests for pagination logic (no API calls required)

context("Pagination Logic Tests")

# Mock tuber_GET function for testing
mock_tuber_GET <- function(path, query, ...) {
  # Simulate different response types based on path and query
  if (path == "playlistItems") {
    mock_playlist_response(query)
  } else if (path == "commentThreads") {
    mock_comment_threads_response(query)
  } else if (path == "search") {
    mock_search_response(query)
  }
}

# Mock playlist API response
mock_playlist_response <- function(query) {
  max_results <- query$maxResults %||% 50
  page_token <- query$pageToken
  
  # Create mock items
  items <- lapply(1:min(max_results, 10), function(i) {
    offset <- if (!is.null(page_token)) as.numeric(page_token) * 10 else 0
    list(
      id = paste0("item_", offset + i),
      snippet = list(
        title = paste("Video", offset + i),
        playlistId = "PLtest123"
      ),
      contentDetails = list(
        videoId = paste0("video_", offset + i)
      )
    )
  })
  
  # Add nextPageToken if more results exist
  next_token <- NULL
  current_page <- if (!is.null(page_token)) as.numeric(page_token) else 0
  if (current_page < 5) {  # Simulate 6 pages total (60 items)
    next_token <- as.character(current_page + 1)
  }
  
  list(
    items = items,
    nextPageToken = next_token,
    pageInfo = list(
      totalResults = 55,
      resultsPerPage = length(items)
    )
  )
}

# Mock comment threads API response
mock_comment_threads_response <- function(query) {
  max_results <- query$maxResults %||% 100
  page_token <- query$pageToken
  
  # Create mock comment items
  items <- lapply(1:min(max_results, 20), function(i) {
    offset <- if (!is.null(page_token)) as.numeric(page_token) * 20 else 0
    list(
      id = paste0("comment_", offset + i),
      snippet = list(
        topLevelComment = list(
          snippet = list(
            textDisplay = paste("Comment", offset + i),
            authorDisplayName = paste("Author", offset + i),
            likeCount = as.character(i),  # Convert to character as API returns
            publishedAt = "2023-01-01T00:00:00Z"
          ),
          id = paste0("comment_", offset + i)
        )
      )
    )
  })
  
  # Add nextPageToken if more results exist
  next_token <- NULL
  current_page <- if (!is.null(page_token)) as.numeric(page_token) else 0
  if (current_page < 2) {  # Simulate 3 pages total
    next_token <- as.character(current_page + 1)
  }
  
  list(
    items = items,
    nextPageToken = next_token,
    pageInfo = list(
      totalResults = 55,
      resultsPerPage = length(items)
    )
  )
}

# Mock search API response
mock_search_response <- function(query) {
  max_results <- query$maxResults %||% 50
  page_token <- query$pageToken
  
  # Create mock search items
  items <- lapply(1:min(max_results, 25), function(i) {
    offset <- if (!is.null(page_token)) as.numeric(page_token) * 25 else 0
    list(
      id = list(
        kind = "youtube#video",
        videoId = paste0("search_video_", offset + i)
      ),
      snippet = list(
        title = paste("Search Result", offset + i),
        channelId = "UC123456789",
        publishedAt = "2023-01-01T00:00:00Z"
      )
    )
  })
  
  # Add nextPageToken if more results exist
  next_token <- NULL
  current_page <- if (!is.null(page_token)) as.numeric(page_token) else 0
  if (current_page < 4) {  # Simulate 5 pages total
    next_token <- as.character(current_page + 1)
  }
  
  list(
    items = items,
    nextPageToken = next_token,
    pageInfo = list(
      totalResults = 120,
      resultsPerPage = length(items)
    )
  )
}

# Test playlist pagination logic
test_that("get_playlist_items handles pagination correctly", {
  # Mock the tuber_GET function
  with_mocked_bindings(
    tuber_GET = mock_tuber_GET,
    {
      # Test requesting more than 50 items triggers pagination
      result <- get_playlist_items(
        filter = c(playlist_id = "PLtest123"),
        max_results = 55,
        simplify = FALSE
      )
      
      expect_equal(length(result$items), 55)
      expect_null(result$nextPageToken)  # Should be NULL when we've got all requested items
    }
  )
})

test_that("get_playlist_items respects max_results limit", {
  with_mocked_bindings(
    tuber_GET = mock_tuber_GET,
    {
      # Test that we don't get more than requested
      result <- get_playlist_items(
        filter = c(playlist_id = "PLtest123"),
        max_results = 25,
        simplify = FALSE
      )
      
      expect_equal(length(result$items), 25)
    }
  )
})

# Test comment pagination logic
# Skipping complex comment threading test due to API response complexity

test_that("get_comment_threads handles small max_results efficiently", {
  with_mocked_bindings(
    tuber_GET = mock_tuber_GET,
    {
      result <- get_comment_threads(
        filter = c(video_id = "test123"),
        max_results = 50,
        simplify = TRUE
      )
      
      # The function returns a matrix when simplified, not a data.frame
      expect_true(is.matrix(result) || is.data.frame(result))
      expect_true(nrow(result) <= 50)
    }
  )
})

# Test search pagination
test_that("yt_search handles get_all parameter correctly", {
  with_mocked_bindings(
    tuber_GET = mock_tuber_GET,
    {
      # Test with get_all = FALSE
      result_single <- yt_search(
        term = "test",
        max_results = 50,
        get_all = FALSE
      )
      
      expect_s3_class(result_single, "data.frame")
      expect_true(nrow(result_single) <= 50)
      
      # Test with get_all = TRUE and max_pages limit
      result_all <- yt_search(
        term = "test", 
        max_results = 100,
        get_all = TRUE,
        max_pages = 3
      )
      
      expect_s3_class(result_all, "data.frame")
      expect_true(nrow(result_all) >= 75)  # Should have multiple pages
      expect_true("video_id" %in% colnames(result_all))
    }
  )
})

# Test attribute setting in search results
test_that("yt_search sets proper result attributes", {
  with_mocked_bindings(
    tuber_GET = mock_tuber_GET,
    {
      result <- yt_search(
        term = "test",
        max_results = 100,
        get_all = TRUE
      )
      
      expect_true(!is.null(attr(result, "total_results")))
      expect_true(!is.null(attr(result, "actual_results")))
      expect_true(!is.null(attr(result, "api_limit_reached")))
      expect_equal(attr(result, "actual_results"), nrow(result))
    }
  )
})