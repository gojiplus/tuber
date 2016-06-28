context("Get Details")

test_that("get_details runs successfully", {

  skip_on_cran()
  
  google_token <- readRDS("token_file.rds")$google_token
  options(google_token=google_token)

  get_info <- yt_get_related_videos(video_id="yJXTXN4xrI8")
  expect_that(get_info, is_a("data.frame"))
})