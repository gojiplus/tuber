context("List Channel Activities")

test_that("list_channel_activities runs successfully", {

  skip_on_cran()

  google_token <- readRDS("token_file.rds")$google_token
  options(google_token = google_token)

  get_info <- list_channel_activities(filter =
                                     c(channel_id = "UCMtFAi84ehTSYSE9XoHefig"))
  expect_that(get_info, is_a("data.frame"))
})
