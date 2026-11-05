test_that("list_playlist_items pages past the 50-item page cap against the live API", {
  skip_if_no_api_key()

  # The uploads playlist of the Google for Developers channel.
  items <- list_playlist_items(playlist_id = "UU_x5XG1OV2P6uZZ5FSM9Ttw", max_results = 55)

  expect_equal(nrow(items), 55)
  expect_false(anyDuplicated(items$playlist_item_id) > 0)
})
