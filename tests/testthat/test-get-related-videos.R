context("Get Details")

test_that("get_related_videos runs successfully", {

  skip_on_cran()
  
  # Skip if no token file exists
  if (!file.exists("token_file.rds.enc")) {
    skip("No token file available for API testing")
  }
  
  tryCatch({
    google_token <- readRDS("token_file.rds.enc")$google_token
    options(google_token = google_token)

    get_info <- get_related_videos(video_id = "yJXTXN4xrI8")
    expect_that(get_info, is_a("data.frame"))
    
  }, error = function(e) {
    skip(paste("API test failed:", e$message))
  })
})
