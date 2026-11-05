test_that("list_channel_activities returns a data frame from the live API", {
  skip_if_no_api_key()

  activities <- list_channel_activities(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw")

  expect_s3_class(activities, "data.frame")
  expect_true("activity_id" %in% names(activities))
})
