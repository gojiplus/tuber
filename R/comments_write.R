#' Post a Top-Level Comment
#'
#' Posts a new top-level comment on a YouTube video. Requires OAuth 2.0
#' authentication. YouTube no longer accepts comments on a channel itself, so
#' a video is required.
#'
#' @param video_id Character. ID of the video to comment on.
#' @param channel_id Character. Optional ID of the channel that owns the video.
#' @param text Character. The text of the comment.
#'
#' @return A list containing the API response.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/commentThreads/insert}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' post_comment(video_id = "yJXTXN4xrI8", text = "Great video!")
#' }
post_comment <- function(video_id, channel_id = NULL, text) {
  assert_string(video_id, min.chars = 1, .var.name = "video_id")
  assert_character(text, len = 1, min.chars = 1, .var.name = "text")

  body <- list(
    snippet = list(
      videoId = video_id,
      topLevelComment = list(
        snippet = list(
          textOriginal = text
        )
      )
    )
  )

  if (!is.null(channel_id)) {
    assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
    body$snippet$channelId <- channel_id
  }

  tuber_POST_json(
    path = "commentThreads",
    query = list(part = "snippet"),
    body = body
  )
}

#' Reply to a Comment
#'
#' Replies to an existing comment.
#' Requires OAuth 2.0 authentication.
#'
#' @param parent_id Character. The ID of the comment being replied to.
#' @param text Character. The text of the reply.
#'
#' @return A list containing the API response.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/comments/insert}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' reply_to_comment(parent_id = "Ugz...", text = "Thanks for watching!")
#' }
reply_to_comment <- function(parent_id, text) {
  assert_character(parent_id, len = 1, min.chars = 1, .var.name = "parent_id")
  assert_character(text, len = 1, min.chars = 1, .var.name = "text")

  body <- list(
    snippet = list(
      parentId = parent_id,
      textOriginal = text
    )
  )

  tuber_POST_json(
    path = "comments",
    query = list(part = "snippet"),
    body = body
  )
}

#' Set Comment Moderation Status
#'
#' Sets the moderation status of one or more comments.
#' Requires OAuth 2.0 authentication and owner privileges.
#'
#' @param comment_ids Character vector. The IDs of the comments to update.
#' @param moderation_status Character. Valid values are 'heldForReview', 'published', 'rejected'.
#' @param ban_author Logical. Whether to ban the author from commenting on the channel. Optional.
#'
#' @return A list containing the API response.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/comments/setModerationStatus}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' set_comment_moderation_status(comment_ids = "Ugz...", moderation_status = "rejected")
#' }
set_comment_moderation_status <- function(comment_ids,
                                          moderation_status,
                                          ban_author = FALSE) {
  assert_character(
    comment_ids,
    min.len = 1,
    any.missing = FALSE,
    min.chars = 1,
    .var.name = "comment_ids"
  )
  assert_choice(
    moderation_status, c("heldForReview", "published", "rejected"),
    .var.name = "moderation_status"
  )
  assert_logical(ban_author, len = 1, .var.name = "ban_author")

  query <- list(
    id = paste(comment_ids, collapse = ","),
    moderationStatus = moderation_status
  )

  if (ban_author) {
    query$banAuthor <- "true"
  }

  tuber_POST_json("comments/setModerationStatus", query = query)
}
