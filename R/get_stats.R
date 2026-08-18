#' Get Video Statistics
#'
#' Retrieves statistics for one or more videos and always returns one row per
#' video found.
#'
#' @param video_ids Character vector of YouTube video IDs.
#' @param include_content_details Include duration, definition, dimension,
#' licensed-content, and projection fields.
#' @param batch_size Number of video IDs per API request, up to 50.
#' @param auth Authentication method, `"token"` or `"key"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame with snake-case column names and one row per video.
#' Count columns are numeric and missing statistics are returned as `NA`.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list}
#' @examples
#' \dontrun{
#' get_video_stats("N708P-A45D0")
#' get_video_stats(c("N708P-A45D0", "M7FIvfx5J10"), auth = "key")
#' }
get_video_stats <- function(video_ids,
                            include_content_details = FALSE,
                            batch_size = 50,
                            auth = "key",
                            ...) {
  assert_character(video_ids, any.missing = FALSE, min.len = 1, .var.name = "video_ids")
  assert_flag(include_content_details, .var.name = "include_content_details")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_choice(auth, c("token", "key"), .var.name = "auth")

  part <- if (include_content_details) {
    c("statistics", "contentDetails")
  } else {
    "statistics"
  }
  details <- get_video_details(
    video_ids = video_ids,
    part = part,
    simplify = TRUE,
    batch_size = batch_size,
    auth = auth,
    ...
  )

  if (!is.data.frame(details) || nrow(details) == 0) {
    empty_result <- data.frame(
      video_id = character(),
      view_count = numeric(),
      like_count = numeric(),
      favorite_count = numeric(),
      comment_count = numeric(),
      stringsAsFactors = FALSE
    )
    if (include_content_details) {
      empty_result$duration <- character()
      empty_result$definition <- character()
      empty_result$dimension <- character()
      empty_result$licensed_content <- logical()
      empty_result$projection <- character()
    }
    return(add_tuber_attributes(
      empty_result,
      api_calls_made = attr(details, "tuber_api_calls") %||% 0,
      function_name = "get_video_stats",
      results_found = 0,
      response_format = "data.frame"
    ))
  }

  result <- data.frame(
    video_id = details$id,
    view_count = as.numeric(details$statistics_viewCount %||% NA),
    like_count = as.numeric(details$statistics_likeCount %||% NA),
    favorite_count = as.numeric(details$statistics_favoriteCount %||% NA),
    comment_count = as.numeric(details$statistics_commentCount %||% NA),
    stringsAsFactors = FALSE
  )

  if (include_content_details) {
    result$duration <- details$contentDetails_duration %||% NA_character_
    result$definition <- details$contentDetails_definition %||% NA_character_
    result$dimension <- details$contentDetails_dimension %||% NA_character_
    result$licensed_content <- details$contentDetails_licensedContent %||% NA
    result$projection <- details$contentDetails_projection %||% NA_character_
  }

  add_tuber_attributes(
    result,
    api_calls_made = attr(details, "tuber_api_calls") %||%
      ceiling(length(unique(video_ids)) / batch_size),
    function_name = "get_video_stats",
    parameters = list(
      video_ids = video_ids,
      include_content_details = include_content_details,
      batch_size = batch_size
    ),
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
