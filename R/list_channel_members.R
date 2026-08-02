#' List Channel Members
#'
#' Retrieves a list of members for a channel associated with the authenticated user.
#' This endpoint requires OAuth 2.0 authentication and the channel must have memberships enabled.
#'
#' @param part Parts to retrieve. Valid values are "snippet". Default is "snippet".
#' @param max_results Maximum number of items to return. Default is 50. Max is 1000.
#' @param page_token Specific page token to retrieve. Optional.
#' @param mode Filter for members. Valid values: "all_current", "newest". Default is "all_current".
#' @param has_access_to_level Filter by a specific membership level ID. Optional.
#' @param simplify Whether to return a simplified data.frame. Default is TRUE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return A data.frame or list of channel members.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/members/list}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' members <- list_channel_members()
#' }
list_channel_members <- function(part = "snippet",
                                 max_results = 50,
                                 page_token = NULL,
                                 mode = "all_current",
                                 has_access_to_level = NULL,
                                 simplify = TRUE,
                                 ...) {

  # Validation
  assert_character(part, min.chars = 1, .var.name = "part")
  assert_integerish(max_results, lower = 1, upper = 1000, .var.name = "max_results")
  assert_choice(mode, c("all_current", "newest"), .var.name = "mode")
  assert_logical(simplify, len = 1, .var.name = "simplify")

  query <- list(
    part = part,
    maxResults = max_results,
    mode = mode
  )

  if (!is.null(page_token)) query$pageToken <- page_token
  if (!is.null(has_access_to_level)) {
    assert_character(has_access_to_level, len = 1, .var.name = "has_access_to_level")
    query$hasAccessToLevel <- has_access_to_level
  }

  fetch_page <- function(token = NULL) {
    q <- query
    if (!is.null(token)) q$pageToken <- token
    tryCatch({
      tuber_GET("members", query = q, auth = "token", ...)
    }, error = function(e) {
      if (grepl("forbidden", tolower(e$message))) {
        abort("Forbidden: Ensure the authenticated channel has Memberships enabled and you are using OAuth2.",
              class = "tuber_members_forbidden")
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
      creatorChannelId = x$snippet$creatorChannelId %||% NA_character_,
      memberDetails_channelId = x$snippet$memberDetails$channelId %||% NA_character_,
      memberDetails_channelUrl = x$snippet$memberDetails$channelUrl %||% NA_character_,
      memberDetails_displayName = x$snippet$memberDetails$displayName %||% NA_character_,
      memberDetails_profileImageUrl = x$snippet$memberDetails$profileImageUrl %||% NA_character_,
      memberSince_snippet_creatorChannelId = x$snippet$memberSince$snippet$creatorChannelId %||% NA_character_,
      memberSince_snippet_memberDetails_channelId = x$snippet$memberSince$snippet$memberDetails$channelId %||% NA_character_,
      memberSince_snippet_memberDetails_channelUrl = x$snippet$memberSince$snippet$memberDetails$channelUrl %||% NA_character_,
      memberSince_snippet_memberDetails_displayName = x$snippet$memberSince$snippet$memberDetails$displayName %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })

  add_tuber_attributes(
    res_df,
    api_calls_made = paginated_data$page_count,
    function_name = "list_channel_members",
    results_found = nrow(res_df),
    response_format = "data.frame"
  )
}
