test_that("list_channel_members handles data correctly", {
  with_mocked_bindings(
    tuber_GET = function(path, query, ...) {
      if (path == "members") {
        list(
          kind = "youtube#memberListResponse",
          etag = "test-etag",
          pageInfo = list(
            totalResults = 1,
            resultsPerPage = 1
          ),
          items = list(
            list(
              kind = "youtube#member",
              etag = "item-etag",
              id = "member-id",
              snippet = list(
                creatorChannelId = "UCcreator",
                memberDetails = list(
                  channelId = "UCmember",
                  channelUrl = "https://youtube.com/UCmember",
                  displayName = "Test Member",
                  profileImageUrl = "https://image.com"
                )
              )
            )
          ),
          nextPageToken = NULL
        )
      }
    },
    {
      result <- list_channel_members()

      expect_true(is.data.frame(result))
      expect_equal(nrow(result), 1)
      expect_equal(result$member_id[1], "member-id")
      expect_equal(result$member_name[1], "Test Member")
    }
  )
})
