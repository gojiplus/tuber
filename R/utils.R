#' Tuber Utility Functions
#'
#' Internal helper functions for common patterns in tuber
#' @name utils
#' @keywords internal
NULL

#' Check if object has items
#'
#' Returns TRUE if x is not NULL and has length > 0
#'
#' @param x Object to check
#' @return Logical indicating if x has items
#' @keywords internal
has_items <- function(x) {
  !is.null(x) && length(x) > 0
}

#' Safely extract field from list/object
#'
#' Extracts a field from an object, returning a default value if the field
#' is missing or NULL.
#'
#' @param obj Object to extract from
#' @param field Field name (character)
#' @param default Default value if field missing. Default: NA_character_
#' @return The field value or default
#' @keywords internal
safe_extract <- function(obj, field, default = NA_character_) {
  if (is.null(obj) || !field %in% names(obj)) {
    return(default)
  }
  result <- obj[[field]]
  if (is.null(result)) default else result
}

#' Safely extract nested field
#'
#' Extracts a value from nested list structures, returning a default value
#' if any level of the path is missing.
#'
#' @param obj Object to extract from
#' @param ... Field names in order (e.g., "author", "id", "value")
#' @param default Default value if any field missing. Default: NA_character_
#' @return The nested field value or default
#' @keywords internal
safe_nested <- function(obj, ..., default = NA_character_) {
  fields <- c(...)
  result <- obj


  for (field in fields) {
    if (is.null(result) || !field %in% names(result)) {
      return(default)
    }
    result <- result[[field]]
  }

  if (is.null(result)) default else result
}

#' Build a standardized comment data frame row
#'
#' Creates a single-row data frame with standardized comment fields.
#' Used by get_all_comments and related functions.
#'
#' @param snippet The comment snippet object from YouTube API
#' @param comment_id The comment ID
#' @param parent_id Parent comment ID for replies, NA for top-level comments
#' @return A single-row data.frame with standardized columns
#' @keywords internal
build_comment_row <- function(snippet, comment_id, parent_id = NA_character_) {
  like_count <- safe_extract(snippet, "likeCount")
  like_count <- if (is.na(like_count)) NA_real_ else as.numeric(like_count)

  data.frame(
    comment_id = comment_id,
    parent_id = parent_id,
    video_id = safe_extract(snippet, "videoId"),
    author_name = safe_extract(snippet, "authorDisplayName"),
    author_channel_id = safe_nested(snippet, "authorChannelId", "value"),
    author_channel_url = safe_extract(snippet, "authorChannelUrl"),
    author_profile_image_url = safe_extract(snippet, "authorProfileImageUrl"),
    text_display = safe_extract(snippet, "textDisplay"),
    text_original = safe_extract(snippet, "textOriginal"),
    can_rate = safe_extract(snippet, "canRate", default = NA),
    viewer_rating = safe_extract(snippet, "viewerRating"),
    like_count = like_count,
    published_at = safe_extract(snippet, "publishedAt"),
    updated_at = safe_extract(snippet, "updatedAt"),
    moderation_status = safe_extract(snippet, "moderationStatus"),
    stringsAsFactors = FALSE
  )
}

empty_comment_frame <- function() {
  build_comment_row(list(), NA_character_)[0, , drop = FALSE]
}

items_to_frame <- function(items, row_builder) {
  template <- row_builder(list())
  if (is.null(items) || length(items) == 0) {
    return(template[0, , drop = FALSE])
  }
  bind_rows(lapply(items, row_builder))
}
