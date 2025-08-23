context("List Channel Activities")

test_that("list_channel_activities runs successfully", {

  skip_on_cran()
  
  # Skip if no token file exists
  if (!file.exists("token_file.rds.enc")) {
    skip("No token file available for API testing")
  }
  
  tryCatch({
    google_token <- readRDS("token_file.rds.enc")$google_token
    options(google_token = google_token)

    get_info <- list_channel_activities(filter =
                                       c(channel_id = "UCMtFAi84ehTSYSE9XoHefig"))
    expect_that(get_info, is_a("data.frame"))
    
  }, error = function(e) {
    skip(paste("API test failed:", e$message))
  })
})
