#' Get Live Chat Messages
#'
#' Retrieves live chat messages for a specific live chat.
#' Note that live chat messages can only be retrieved for active live broadcasts.
#'
#' @param live_chat_id Character. The id of the live chat.
#' @param part Character. Parts to retrieve. Valid values are "snippet", "authorDetails". Default is "snippet,authorDetails".
#' @param hl Character. Language used for text values. Optional.
#' @param max_results Integer. Maximum number of items to return. Default is 500. Max is 2000.
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
#' messages <- get_live_chat_messages(live_chat_id = "Cg0KC...")
#' }
get_live_chat_messages <- function(live_chat_id,
                                   part = "snippet,authorDetails",
                                   hl = NULL,
                                   max_results = 500,
                                   page_token = NULL,
                                   profile_image_size = NULL,
                                   simplify = TRUE,
                                   ...) {

  # Validation
  assert_character(live_chat_id, len = 1, min.chars = 1, .var.name = "live_chat_id")
  assert_character(part, min.chars = 1, .var.name = "part")
  assert_integerish(max_results, lower = 1, upper = 2000, .var.name = "max_results")
  assert_logical(simplify, len = 1, .var.name = "simplify")

  query <- list(
    liveChatId = live_chat_id,
    part = part,
    maxResults = max_results
  )

  if (!is.null(page_token)) query$pageToken <- page_token
  if (!is.null(hl)) {
    assert_character(hl, len = 1, .var.name = "hl")
    query$hl <- hl
  }
  if (!is.null(profile_image_size)) {
    assert_integerish(profile_image_size, lower = 16, upper = 1024, .var.name = "profile_image_size")
    query$profileImageSize <- profile_image_size
  }

  fetch_page <- function(token = NULL) {
    q <- query
    if (!is.null(token)) q$pageToken <- token
    tuber_GET("liveChatMessages", query = q, ...)
  }

  initial_res <- fetch_page(page_token)

  if (is.null(initial_res$items) || length(initial_res$items) == 0) {
    if (simplify) return(data.frame())
    return(initial_res)
  }

  # Pagination
  paginated_data <- paginate_api_request(
    initial_response = initial_res,
    fetch_next_page_fn = fetch_page,
    max_results = max_results
  )

  if (!simplify) {
    initial_res$items <- paginated_data$items
    return(initial_res)
  }

  # Simplify to data frame
  res_df <- map_df(paginated_data$items, function(x) {
    data.frame(
      id = x$id %||% NA_character_,
      type = x$snippet$type %||% NA_character_,
      liveChatId = x$snippet$liveChatId %||% NA_character_,
      authorChannelId = x$snippet$authorChannelId %||% NA_character_,
      publishedAt = x$snippet$publishedAt %||% NA_character_,
      hasDisplayContent = x$snippet$hasDisplayContent %||% NA,
      displayMessage = x$snippet$displayMessage %||% NA_character_,
      textMessageDetails_messageText = x$snippet$textMessageDetails$messageText %||% NA_character_,
      authorDetails_channelId = x$authorDetails$channelId %||% NA_character_,
      authorDetails_channelUrl = x$authorDetails$channelUrl %||% NA_character_,
      authorDetails_displayName = x$authorDetails$displayName %||% NA_character_,
      authorDetails_profileImageUrl = x$authorDetails$profileImageUrl %||% NA_character_,
      authorDetails_isVerified = x$authorDetails$isVerified %||% NA,
      authorDetails_isChatOwner = x$authorDetails$isChatOwner %||% NA,
      authorDetails_isChatSponsor = x$authorDetails$isChatSponsor %||% NA,
      authorDetails_isChatModerator = x$authorDetails$isChatModerator %||% NA,
      stringsAsFactors = FALSE
    )
  })

  add_tuber_attributes(
    res_df,
    api_calls_made = paginated_data$page_count,
    function_name = "get_live_chat_messages",
    results_found = nrow(res_df),
    response_format = "data.frame"
  )
}
