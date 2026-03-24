#' Get Super Chat Events
#'
#' Retrieves Super Chat events for a channel associated with the authenticated user.
#' This endpoint requires OAuth 2.0 authentication and the channel must be approved for Super Chat.
#'
#' @param part Parts to retrieve. Valid values are "snippet". Default is "snippet".
#' @param hl Language used for text values. Optional.
#' @param max_results Maximum number of items to return. Default is 50. Max is 50.
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
#' super_chats <- get_super_chat_events()
#' }
get_super_chat_events <- function(part = "snippet",
                                  hl = NULL,
                                  max_results = 50,
                                  page_token = NULL,
                                  simplify = TRUE,
                                  ...) {

  # Validation
  assert_character(part, min.chars = 1, .var.name = "part")
  assert_integerish(max_results, lower = 1, upper = 50, .var.name = "max_results")
  assert_logical(simplify, len = 1, .var.name = "simplify")

  query <- list(
    part = part,
    maxResults = max_results,
    pageToken = page_token
  )

  if (!is.null(hl)) {
    assert_character(hl, len = 1, .var.name = "hl")
    query$hl <- hl
  }

  fetch_page <- function(token = NULL) {
    q <- query
    if (!is.null(token)) q$pageToken <- token
    tryCatch({
      tuber_GET("superChatEvents", query = q, auth = "token", ...)
    }, error = function(e) {
      if (grepl("forbidden", tolower(e$message))) {
        abort("Forbidden: Ensure the authenticated channel has Super Chat enabled and you are using OAuth2.",
              class = "tuber_super_chat_forbidden")
      } else {
        stop(e)
      }
    })
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
      channelId = x$snippet$channelId %||% NA_character_,
      supporterDetails_channelId = x$snippet$supporterDetails$channelId %||% NA_character_,
      supporterDetails_channelUrl = x$snippet$supporterDetails$channelUrl %||% NA_character_,
      supporterDetails_displayName = x$snippet$supporterDetails$displayName %||% NA_character_,
      commentText = x$snippet$commentText %||% NA_character_,
      createdAt = x$snippet$createdAt %||% NA_character_,
      amountMicros = x$snippet$amountMicros %||% NA_character_,
      currency = x$snippet$currency %||% NA_character_,
      displayString = x$snippet$displayString %||% NA_character_,
      messageType = x$snippet$messageType %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })

  add_tuber_attributes(
    res_df,
    api_calls_made = paginated_data$page_count,
    function_name = "get_super_chat_events",
    results_found = nrow(res_df),
    response_format = "data.frame"
  )
}
