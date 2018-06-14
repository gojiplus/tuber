context("List Channel Sections")

skip_on_cran()

test_that("list_channel_sections runs successfully", {

  skip_on_cran()

  google_token <- readRDS("token_file.rds")$google_token
  options(google_token = google_token)

  get_info <- list_channel_sections(c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA"))
  expect_that(get_info, is_a("list"))
})


test_that("list_my_channel runs successfully", {

  google_token <- readRDS("token_file.rds")$google_token
  options(google_token = google_token)

  get_info <- list_my_channel()
  expect_that(get_info, is_a("list"))
})
