test_that("get_super_chat_events handles data correctly", {
  with_mocked_bindings(
    tuber_GET = function(path, query, ...) {
      if (path == "superChatEvents") {
        list(
          kind = "youtube#superChatEventListResponse",
          etag = "test-etag",
          pageInfo = list(
            totalResults = 1,
            resultsPerPage = 1
          ),
          items = list(
            list(
              kind = "youtube#superChatEvent",
              etag = "item-etag",
              id = "test-id",
              snippet = list(
                channelId = "UCtest",
                supporterDetails = list(
                  channelId = "UCsupporter",
                  channelUrl = "https://youtube.com/UCsupporter",
                  displayName = "Test Supporter"
                ),
                commentText = "Great stream!",
                createdAt = "2024-01-01T00:00:00Z",
                amountMicros = "5000000",
                currency = "USD",
                displayString = "$5.00",
                messageType = 1
              )
            )
          ),
          nextPageToken = NULL
        )
      }
    },
    
    {
      result <- get_super_chat_events()
      
      expect_true(is.data.frame(result))
      expect_equal(nrow(result), 1)
      expect_equal(result$id[1], "test-id")
      expect_equal(result$currency[1], "USD")
      expect_equal(result$supporterDetails_displayName[1], "Test Supporter")
    }
  )
})

test_that("get_super_chat_events handles forbidden error gracefully", {
  with_mocked_bindings(
    tuber_GET = function(path, query, ...) {
      stop("forbidden: The request is not authorized.")
    },
    
    {
      expect_error(get_super_chat_events(), class = "tuber_super_chat_forbidden")
    }
  )
})
