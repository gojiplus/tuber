#' List Super Chat Events
#'
#' Retrieves Super Chat events for a channel associated with the authenticated user.
#' This endpoint requires OAuth 2.0 authentication and the channel must be approved for Super Chat.
#'
#' @param part Parts to retrieve. Valid values are "snippet". Default is "snippet".
#' @param language Optional language code for localized text.
#' @param max_results Maximum total number of events to return.
#' @param page_token Specific page token to retrieve. Optional.
#' @param simplify Whether to return a simplified data.frame. Default is TRUE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return A data.frame or list of Super Chat events.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/live/docs/superChatEvents/list}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' super_chats <- list_super_chat_events()
#' }
list_super_chat_events <- function(part = "snippet",
                                   language = NULL,
                                   max_results = 50,
                                   page_token = NULL,
                                   simplify = TRUE,
                                   ...) {
  # Validation
  assert_character(part, min.len = 1, min.chars = 1, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")

  query <- list(
    part = paste(part, collapse = ","),
    maxResults = min(max_results, 50),
    pageToken = page_token
  )

  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
    query$hl <- language
  }

  fetch_page <- function(token = NULL) {
    q <- query
    if (!is.null(token)) q$pageToken <- token
    tryCatch(
      {
        tuber_GET("superChatEvents", query = q, auth = "token", ...)
      },
      error = function(e) {
        if (grepl("forbidden", tolower(e$message))) {
          abort(
            paste(
              "Forbidden: Ensure the authenticated channel has Super Chat",
              "enabled and you are using OAuth2."
            ),
            class = "tuber_super_chat_forbidden"
          )
        } else {
          stop(e)
        }
      }
    )
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
      function_name = "list_super_chat_events",
      results_found = length(paginated_data$items),
      response_format = "list"
    ))
  }

  res_df <- items_to_frame(paginated_data$items, function(x) {
    data.frame(
      event_id = x$id %||% NA_character_,
      channel_id = x$snippet$channelId %||% NA_character_,
      supporter_channel_id = x$snippet$supporterDetails$channelId %||% NA_character_,
      supporter_channel_url = x$snippet$supporterDetails$channelUrl %||% NA_character_,
      supporter_name = x$snippet$supporterDetails$displayName %||% NA_character_,
      comment_text = x$snippet$commentText %||% NA_character_,
      created_at = x$snippet$createdAt %||% NA_character_,
      amount_micros = as.numeric(x$snippet$amountMicros %||% NA),
      currency = x$snippet$currency %||% NA_character_,
      display_string = x$snippet$displayString %||% NA_character_,
      message_type = x$snippet$messageType %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })

  add_tuber_attributes(
    res_df,
    api_calls_made = paginated_data$page_count,
    function_name = "list_super_chat_events",
    results_found = nrow(res_df),
    response_format = "data.frame"
  )
}
