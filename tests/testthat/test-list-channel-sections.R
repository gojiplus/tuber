skip_on_cran()

test_that("get_my_channel returns the authenticated channel from the live API", {
  skip_if_no_oauth_token()

  channel <- get_my_channel()

  expect_s3_class(channel, "data.frame")
  expect_equal(nrow(channel), 1)
})
