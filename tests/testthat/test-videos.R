test_that("get_video_details returns one live video", {
  skip_if_no_api_key()

  details <- get_video_details(video_ids = "dQw4w9WgXcQ")

  expect_s3_class(details, "data.frame")
  expect_equal(details$id, "dQw4w9WgXcQ")
})

test_that("get_video_details returns several live videos in one batch", {
  skip_if_no_api_key()
  ids <- c("dQw4w9WgXcQ", "kJQP7kiw5Fk")

  details <- get_video_details(video_ids = ids)

  expect_setequal(details$id, ids)
  expect_true(all(c("items_kind", "snippet_channelTitle") %in% names(details)))
  expect_equal(attr(details, "tuber_api_calls"), 1)
})
