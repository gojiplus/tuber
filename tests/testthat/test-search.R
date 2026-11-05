test_that("yt_search obeys max_results against the live API", {
  skip_if_no_api_key()

  res <- yt_search(term = "cats", type = "channel", max_results = 5)

  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 0)
  expect_lte(nrow(res), 5)
})

test_that("yt_search pages past the 50-item page cap against the live API", {
  skip_if_no_api_key()

  res <- yt_search(term = "cats", type = "video", max_results = 55)

  expect_gt(nrow(res), 50)
  expect_lte(nrow(res), 55)
  expect_false(anyDuplicated(res$video_id) > 0)
})
