test_that("get_all_comments returns comments and replies from the live API", {
  skip_if_no_api_key()

  comments <- get_all_comments(video_id = "dQw4w9WgXcQ", max_results = 150)

  expect_s3_class(comments, "data.frame")
  expect_gt(nrow(comments), 0)
  expect_lte(nrow(comments), 150)
  expect_true(all(
    c("author_name", "text_display", "published_at", "comment_id") %in% names(comments)
  ))
})

test_that("get_all_comments handles pagination correctly", {
  # Create a mock that simulates paginated responses
  mock_tuber_GET_paginated <- function(endpoint, query, ...) { # nolint: object_name_linter.
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
      expect_equal(nrow(result), 15) # 3 pages * 5 comments each
      expect_true(all(c("text_display", "author_name") %in% colnames(result)))

      # Check that we got comments from all pages
      expect_true(any(grepl("page 1", result$text_display)))
      expect_true(any(grepl("page 2", result$text_display)))
      expect_true(any(grepl("page 3", result$text_display)))
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
      expect_warning(
        result <- get_all_comments(video_id = "empty_video"),
        "No comments found"
      )
      expect_s3_class(result, "data.frame")
      expect_equal(nrow(result), 0)
    }
  )
})
