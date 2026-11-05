test_that("list_playlists pages past the 50-item page cap against the live API", {
  skip_if_no_api_key()

  playlists <- list_playlists(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw", max_results = 55)

  expect_equal(nrow(playlists), 55)
  expect_false(anyDuplicated(playlists$playlist_id) > 0)
})
