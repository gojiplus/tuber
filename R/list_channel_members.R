#' List Channel Members
#'
#' Retrieves a list of members for a channel associated with the authenticated user.
#' This endpoint requires OAuth 2.0 authentication and the channel must have memberships enabled.
#'
#' @param part Parts to retrieve. Valid values are "snippet". Default is "snippet".
#' @param max_results Maximum total number of members to return.
#' @param page_token Specific page token to retrieve. Optional.
#' @param mode Member stream, `"all_current"` or `"updates"`.
#' @param has_access_to_level Filter by a specific membership level ID. Optional.
#' @param filter_by_member_channel_ids Optional member channel IDs whose
#' membership status should be checked. YouTube accepts at most 100 per call.
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
#' yt_oauth("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET", scope = "channel_memberships")
#' members <- list_channel_members()
#' }
list_channel_members <- function(part = "snippet",
                                 max_results = 50,
                                 page_token = NULL,
                                 mode = "all_current",
                                 has_access_to_level = NULL,
                                 filter_by_member_channel_ids = NULL,
                                 simplify = TRUE,
                                 ...) {
  # Validation
  assert_character(part, min.len = 1, min.chars = 1, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_choice(mode, c("all_current", "updates"), .var.name = "mode")
  assert_flag(simplify, .var.name = "simplify")

  query <- list(
    part = paste(part, collapse = ","),
    maxResults = min(max_results, 1000),
    mode = mode
  )

  if (!is.null(page_token)) query$pageToken <- page_token
  if (!is.null(has_access_to_level)) {
    assert_character(has_access_to_level, len = 1, .var.name = "has_access_to_level")
    query$hasAccessToLevel <- has_access_to_level
  }
  if (!is.null(filter_by_member_channel_ids)) {
    assert_character(
      filter_by_member_channel_ids,
      min.len = 1,
      max.len = 100,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "filter_by_member_channel_ids"
    )
    query$filterByMemberChannelId <- paste(filter_by_member_channel_ids, collapse = ",")
  }

  fetch_page <- function(token = NULL) {
    q <- query
    if (!is.null(token)) q$pageToken <- token
    tryCatch(
      {
        tuber_GET("members", query = q, auth = "token", ...)
      },
      error = function(e) {
        if (grepl("forbidden", tolower(e$message))) {
          abort(
            paste(
              "Forbidden: Ensure the authenticated channel has Memberships",
              "enabled and you are using OAuth2."
            ),
            class = "tuber_members_forbidden"
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
      function_name = "list_channel_members",
      results_found = length(paginated_data$items),
      response_format = "list"
    ))
  }

  res_df <- items_to_frame(paginated_data$items, function(x) {
    data.frame(
      member_id = x$id %||% NA_character_,
      creator_channel_id = x$snippet$creatorChannelId %||% NA_character_,
      member_channel_id = x$snippet$memberDetails$channelId %||% NA_character_,
      member_channel_url = x$snippet$memberDetails$channelUrl %||% NA_character_,
      member_name = x$snippet$memberDetails$displayName %||% NA_character_,
      member_profile_image_url = x$snippet$memberDetails$profileImageUrl %||% NA_character_,
      highest_accessible_level = x$snippet$membershipsDetails$highestAccessibleLevel %||%
        NA_character_,
      highest_accessible_level_name =
        x$snippet$membershipsDetails$highestAccessibleLevelDisplayName %||% NA_character_,
      accessible_levels = I(list(
        x$snippet$membershipsDetails$accessibleLevels %||% character()
      )),
      member_since = x$snippet$membershipsDetails$membershipsDuration$memberSince %||%
      NA_character_,
      member_total_duration_months = as.integer(
        x$snippet$membershipsDetails$membershipsDuration$memberTotalDurationMonths %||% NA
      ),
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
