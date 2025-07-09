context("Get Playlists")

test_that("get_playlists returns >50 results when requested", {
  skip_on_cran()
  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  res <- get_playlists(filter = c(channel_id = "UCBR8-60-B28hp2BmDPdntcQ"), max_results = 55)
  expect_true(length(res$items) >= 55)
})
