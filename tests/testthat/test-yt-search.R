context("YT Search")

test_that("yt_search obeys max_results", {
  skip_on_cran()
  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  res <- yt_search(term = "cats", type = "channel", max_results = 5)
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 5)
})

test_that("yt_search returns >50 results when requested", {
  skip_on_cran()
  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  res <- yt_search(term = "cats", type = "video", max_results = 55)
  expect_s3_class(res, "data.frame")
  expect_true(nrow(res) >= 55)
})
