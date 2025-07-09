context("Get Playlists")

test_that("get_playlists accepts q parameter", {
  skip_on_cran()

  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  res <- get_playlists(filter = c(channel_id = "UCMtFAi84ehTSYSE9XoHefig"), q = "music")
  expect_true(is.list(res))
})
