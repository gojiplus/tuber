test_that("get_live_chat_messages handles data correctly", {
  with_mocked_bindings(
    tuber_GET = function(path, query, ...) {
      if (path == "liveChatMessages") {
        list(
          kind = "youtube#liveChatMessageListResponse",
          etag = "test-etag",
          pageInfo = list(
            totalResults = 1,
            resultsPerPage = 1
          ),
          items = list(
            list(
              kind = "youtube#liveChatMessage",
              etag = "item-etag",
              id = "message-id",
              snippet = list(
                type = "textMessageEvent",
                liveChatId = "chat-id",
                authorChannelId = "author-id",
                publishedAt = "2024-01-01T00:00:00Z",
                hasDisplayContent = TRUE,
                displayMessage = "Hello World!",
                textMessageDetails = list(
                  messageText = "Hello World!"
                )
              ),
              authorDetails = list(
                channelId = "author-id",
                channelUrl = "https://youtube.com/author",
                displayName = "Test Author",
                profileImageUrl = "https://image.com",
                isVerified = FALSE,
                isChatOwner = FALSE,
                isChatSponsor = TRUE,
                isChatModerator = FALSE
              )
            )
          ),
          nextPageToken = NULL
        )
      }
    },

    {
      result <- get_live_chat_messages(live_chat_id = "chat-id")

      expect_true(is.data.frame(result))
      expect_equal(nrow(result), 1)
      expect_equal(result$id[1], "message-id")
      expect_equal(result$displayMessage[1], "Hello World!")
      expect_equal(result$authorDetails_displayName[1], "Test Author")
      expect_true(result$authorDetails_isChatSponsor[1])
    }
  )
})
