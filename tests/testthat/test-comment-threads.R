test_that("list_comment_threads pages past the 100-item page cap against the live API", {
  skip_if_no_api_key()

  threads <- list_comment_threads(video_id = "dQw4w9WgXcQ", max_results = 101)

  expect_s3_class(threads, "data.frame")
  expect_equal(nrow(threads), 101)
  expect_false(anyDuplicated(threads$thread_id) > 0)
})
