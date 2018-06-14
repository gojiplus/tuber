context("List Captions")

test_that("list_captions runs successfully", {

  skip_on_cran()

  google_token <- readRDS("token_file.rds")$google_token
  options(google_token = google_token)

  video_id <- "M7FIvfx5J10"
  get_info <- list_caption_tracks(video_id = video_id)
  expect_that(get_info, is_a("list"))
})
