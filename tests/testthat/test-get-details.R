context("Get Details")

test_that("get_video_details runs successfully", {

  skip_on_cran()

  google_token <- readRDS("token_file.rds")$google_token
  options(google_token = google_token)

  get_info <- get_video_details(video_id = "N708P-A45D0")
  expect_that(get_info, is_a("list"))
})

context("Get Details as Data Frame")

test_that("get_video_details(as.data.frame = TRUE) runs successfully for multiple videos", {

  skip_on_cran()

  google_token <- readRDS("token_file.rds")$google_token
  options(google_token = google_token)

  get_info <- get_video_details(
    video_id = c("LDZX4ooRsWs", "yJXTXN4xrI8"),
    as.data.frame = TRUE)
  expect_that(get_info, is_a("data.frame"))
})
