context("Get Details")

test_that("get_video_details runs successfully", {

  skip_on_cran()

  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  get_info <- get_video_details(video_id = "N708P-A45D0")
  expect_true(is.list(get_info))
})

context("Get Details as Data Frame")

test_that("get_video_details(as.data.frame = TRUE) runs successfully for multiple videos", {

  skip_on_cran()

  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  get_info <- get_video_details(
    video_id = c("LDZX4ooRsWs", "yJXTXN4xrI8"),
    as.data.frame = TRUE)
  expect_s3_class(get_info, "data.frame")
  expect_true(all(c("items_kind", "channelTitle") %in% names(get_info)))
})
