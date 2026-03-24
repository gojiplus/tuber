test_that("post_comment validates arguments", {
  expect_error(post_comment(text = "Hello"), "Either video_id or channel_id")
  expect_error(post_comment(video_id = "vid"), "argument \"text\" is missing")
})

test_that("post_comment formulates correct payload", {
  with_mocked_bindings(
    tuber_POST_json = function(path, query, body, ...) {
      expect_equal(path, "commentThreads")
      expect_equal(body$snippet$topLevelComment$snippet$textOriginal, "Test")
      expect_equal(body$snippet$videoId, "vid123")
      list(kind = "youtube#commentThread", id = "thread123")
    },
    
    {
      res <- post_comment(video_id = "vid123", text = "Test")
      expect_equal(res$id, "thread123")
    }
  )
})

test_that("reply_to_comment formulates correct payload", {
  with_mocked_bindings(
    tuber_POST_json = function(path, query, body, ...) {
      expect_equal(path, "comments")
      expect_equal(body$snippet$parentId, "parent123")
      expect_equal(body$snippet$textOriginal, "Reply text")
      list(kind = "youtube#comment", id = "reply123")
    },
    
    {
      res <- reply_to_comment(parent_id = "parent123", text = "Reply text")
      expect_equal(res$id, "reply123")
    }
  )
})

test_that("set_comment_moderation_status formulates correct request", {
  with_mocked_bindings(
    yt_check_token = function() TRUE,
    tuber_check = function(req) invisible(TRUE),
    content = function(req) list(),
    {
      with_mocked_bindings(
        POST = function(url, query, ...) {
          expect_true(grepl("setModerationStatus", url))
          expect_equal(query$id, "comm1")
          expect_equal(query$moderationStatus, "rejected")
          expect_equal(query$banAuthor, "true")
          
          res <- list(status_code = 204, request = list(), url = "https://example.com/mock")
          class(res) <- "response"
          res
        },
        .package = "httr",
        
        {
          res <- set_comment_moderation_status(comment_id = "comm1", moderation_status = "rejected", ban_author = TRUE)
          expect_true(is.list(res))
        }
      )
    }
  )
})
