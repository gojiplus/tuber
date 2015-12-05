context("Get Details")

test_that("get_details runs successfully", {
  skip_on_cran()
  get_info <- get_details(video_id="N708P-A45D0")
  expect_that(get_info, is_a("list"))
})