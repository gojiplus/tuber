context("Get All Comments")

test_that("get_all_comments handles videos with no comments", {
  skip_on_cran()
  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  expect_message(
    res <- get_all_comments(video_id = "XqZsoesa55w"),
    "No comments found"
  )
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0L)
})
