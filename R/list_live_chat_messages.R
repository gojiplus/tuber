#' List Live Chat Messages
#'
#' Retrieves live chat messages for a specific live chat.
#' Note that live chat messages can only be retrieved for active live broadcasts.
#'
#' @param live_chat_id Character. The id of the live chat.
#' @param part Character. Parts to retrieve. Valid values are "snippet", "authorDetails". Default is
#' "snippet,authorDetails".
#' @param language Optional language code for localized text.
#' @param max_results Maximum total number of messages to return.
#' @param page_token Character. Specific page token to retrieve. Optional.
#' @param profile_image_size Integer. Size of the profile image to return. Optional.
#' @param simplify Logical. Whether to return a simplified data.frame. Default is TRUE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return A data.frame or list of live chat messages.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/live/docs/liveChatMessages/list}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' messages <- list_live_chat_messages(live_chat_id = "Cg0KC...")
#' }
list_live_chat_messages <- function(live_chat_id,
                                    part = "snippet,authorDetails",
                                    language = NULL,
                                    max_results = 500,
                                    page_token = NULL,
                                    profile_image_size = NULL,
                                    simplify = TRUE,
                                    ...) {
  # Validation
  assert_character(live_chat_id, len = 1, min.chars = 1, .var.name = "live_chat_id")
  assert_character(part, min.len = 1, min.chars = 1, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")

  query <- list(
    liveChatId = live_chat_id,
    part = paste(part, collapse = ","),
    maxResults = max(200, min(max_results, 2000))
  )

  if (!is.null(page_token)) query$pageToken <- page_token
  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
    query$hl <- language
  }
  if (!is.null(profile_image_size)) {
    assert_integerish(
      profile_image_size,
      len = 1,
      lower = 16,
      upper = 720,
      .var.name = "profile_image_size"
    )
    query$profileImageSize <- profile_image_size
  }

  fetch_page <- function(token = NULL) {
    q <- query
    if (!is.null(token)) q$pageToken <- token
    tuber_GET("liveChatMessages", query = q, ...)
  }

  initial_res <- fetch_page(page_token)

  paginated_data <- paginate_api_request(
    initial_response = initial_res,
    fetch_next_page_fn = fetch_page,
    max_results = max_results
  )

  if (!simplify) {
    initial_res$items <- paginated_data$items
    initial_res$nextPageToken <- paginated_data$final_page_token
    return(add_tuber_attributes(
      initial_res,
      api_calls_made = paginated_data$page_count,
      function_name = "list_live_chat_messages",
      results_found = length(paginated_data$items),
      response_format = "list"
    ))
  }

  res_df <- items_to_frame(paginated_data$items, function(x) {
    data.frame(
      message_id = x$id %||% NA_character_,
      type = x$snippet$type %||% NA_character_,
      live_chat_id = x$snippet$liveChatId %||% NA_character_,
      author_channel_id = x$authorDetails$channelId %||%
        x$snippet$authorChannelId %||% NA_character_,
      published_at = x$snippet$publishedAt %||% NA_character_,
      has_display_content = x$snippet$hasDisplayContent %||% NA,
      display_message = x$snippet$displayMessage %||% NA_character_,
      message_text = x$snippet$textMessageDetails$messageText %||% NA_character_,
      author_channel_url = x$authorDetails$channelUrl %||% NA_character_,
      author_name = x$authorDetails$displayName %||% NA_character_,
      author_profile_image_url = x$authorDetails$profileImageUrl %||% NA_character_,
      author_is_verified = x$authorDetails$isVerified %||% NA,
      author_is_chat_owner = x$authorDetails$isChatOwner %||% NA,
      author_is_chat_sponsor = x$authorDetails$isChatSponsor %||% NA,
      author_is_chat_moderator = x$authorDetails$isChatModerator %||% NA,
      stringsAsFactors = FALSE
    )
  })

  add_tuber_attributes(
    res_df,
    api_calls_made = paginated_data$page_count,
    function_name = "list_live_chat_messages",
    results_found = nrow(res_df),
    response_format = "data.frame"
  )
}
