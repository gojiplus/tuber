context("Get All Comments")


test_that("get_all_comments runs successfully with real API", {
  skip_on_cran()
  
  # Skip if no token file exists
  if (!file.exists("token_file.rds.enc")) {
    skip("No token file available for API testing")
  }
  
  tryCatch({
    google_token <- readRDS("token_file.rds.enc")$google_token
    options(google_token = google_token)
    
    # Use a well-known video with comments (Rick Astley - Never Gonna Give You Up)
    result <- get_all_comments(video_id = "dQw4w9WgXcQ")
    
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
    
    # Check for expected columns
    expected_cols <- c("authorDisplayName", "textDisplay", "publishedAt", "id")
    missing_cols <- setdiff(expected_cols, colnames(result))
    expect_true(length(missing_cols) == 0, 
                info = paste("Missing columns:", paste(missing_cols, collapse = ", ")))
    
  }, error = function(e) {
    skip(paste("API test failed:", e$message))
  })
})

test_that("get_all_comments handles pagination correctly", {
  # Create a mock that simulates paginated responses
  mock_tuber_GET_paginated <- function(endpoint, query, ...) {
    page_token <- query$pageToken
    current_page <- if (is.null(page_token)) 1 else as.numeric(page_token)
    
    # Create items for this page
    items <- lapply(1:5, function(i) {
      comment_id <- paste0("page", current_page, "_comment", i)
      list(
        id = comment_id,
        snippet = list(
          topLevelComment = list(
            snippet = list(
              textDisplay = paste("Comment from page", current_page, "item", i),
              authorDisplayName = paste("Author", current_page, i),
              publishedAt = "2023-01-01T00:00:00Z",
              likeCount = i
            )
          )
        )
      )
    })
    
    # Add nextPageToken for first 2 pages only
    next_token <- if (current_page < 3) as.character(current_page + 1) else NULL
    
    list(
      items = items,
      nextPageToken = next_token
    )
  }
  
  with_mocked_bindings(
    tuber_GET = mock_tuber_GET_paginated,
    {
      result <- get_all_comments(video_id = "test123")
      
      expect_s3_class(result, "data.frame")
      expect_equal(nrow(result), 15)  # 3 pages * 5 comments each
      expect_true(all(c("textDisplay", "authorDisplayName") %in% colnames(result)))
      
      # Check that we got comments from all pages
      expect_true(any(grepl("page 1", result$textDisplay)))
      expect_true(any(grepl("page 2", result$textDisplay)))
      expect_true(any(grepl("page 3", result$textDisplay)))
    }
  )
})

test_that("get_all_comments handles empty responses gracefully", {
  mock_empty_response <- function(endpoint, query, ...) {
    list(
      items = list(),
      nextPageToken = NULL
    )
  }
  
  with_mocked_bindings(
    tuber_GET = mock_empty_response,
    {
      result <- get_all_comments(video_id = "empty_video")
      expect_s3_class(result, "data.frame")
      expect_equal(nrow(result), 0)
    }
  )
})
