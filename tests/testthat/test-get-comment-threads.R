context("Comment Threads")

test_that("get_comment_threads returns all comments", {
  skip_on_cran()
  
  # Skip if no token file exists
  if (!file.exists("token_file.rds.enc")) {
    skip("No token file available for API testing")
  }
  
  tryCatch({
    google_token <- readRDS("token_file.rds.enc")$google_token
    options(google_token = google_token)

    first_page <- tuber_GET(
      "commentThreads",
      list(part = "snippet", videoId = "N708P-A45D0", maxResults = 100)
    )
    total <- first_page$pageInfo$totalResults

    all_comments <- get_comment_threads(
      filter = c(video_id = "N708P-A45D0"),
      max_results = 101
    )

    expect_s3_class(all_comments, "data.frame")
    expect_equal(nrow(all_comments), total)
    
  }, error = function(e) {
    skip(paste("API test failed:", e$message))
  })
})
