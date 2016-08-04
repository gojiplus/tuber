context("Get Details")

test_that("get_details runs successfully", {

  skip_on_cran()
  
  google_token <- readRDS("token_file.rds")$google_token
  options(google_token=google_token)

  get_info <- get_video_details(video_id="N708P-A45D0")
  expect_that(get_info, is_a("list"))
})