context("Get All Comments")

test_that("get_all_comments returns all comments", {
  skip_on_cran()
  google_token <- readRDS("token_file.rds.enc")$google_token
  options(google_token = google_token)

  first_page <- tuber:::tuber_GET("commentThreads",
                                  query = list(videoId = "a-UQz7fqR3w",
                                               part = "snippet"))
  total <- first_page$pageInfo$totalResults

  res <- get_all_comments(video_id = "a-UQz7fqR3w")
  expect_equal(attr(res, "total_results"), total)
})
