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
  seen <- new.env(parent = emptyenv())

  with_mocked_bindings(
    yt_check_token = function() TRUE,
    yt_access_token = function() "fake-token",
    track_quota_usage = function(...) invisible(NULL),
    {
      httr2::local_mocked_responses(function(req) {
        seen$req <- req
        httr2::response(status_code = 204L)
      })

      res <- set_comment_moderation_status(
        comment_id = "comm1", moderation_status = "rejected",
        ban_author = TRUE
      )

      url <- httr2::url_parse(seen$req$url)
      expect_equal(url$path, "/youtube/v3/comments/setModerationStatus")
      expect_equal(url$query$id, "comm1")
      expect_equal(url$query$moderationStatus, "rejected")
      expect_equal(url$query$banAuthor, "true")
      expect_equal(seen$req$method, "POST")
      # A 204 carries no body; the function must not try to parse one.
      expect_null(res)
    }
  )
})
