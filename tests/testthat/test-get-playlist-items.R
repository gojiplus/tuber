context("Get Playlist Items")

test_that("get_playlist_items returns >50 results when requested", {
  skip_on_cran()
  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  res <- get_playlist_items(filter = c(playlist_id = "PLrEnWoR732-CN09YykVof2lxdI3MLOZda"), max_results = 55)
  expect_true(length(res$items) >= 55)
})
