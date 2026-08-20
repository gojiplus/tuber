#' List Caption Tracks
#'
#' Lists caption-track metadata for a video. The caption text itself is
#' returned by [download_caption()]. YouTube requires OAuth authorization for
#' this method.
#'
#' @param video_id YouTube video ID.
#' @param caption_ids Optional character vector of caption-track IDs to select.
#' @param part Character vector of caption resource parts.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a caption-list
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/captions/list}
#' @examples
#' \dontrun{
#' list_captions(video_id = "M7FIvfx5J10")
#' }
list_captions <- function(video_id,
                          caption_ids = NULL,
                          part = "snippet",
                          simplify = TRUE,
                          ...) {
  assert_string(video_id, min.chars = 1, .var.name = "video_id")
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_flag(simplify, .var.name = "simplify")
  if (!is.null(caption_ids)) {
    assert_character(
      caption_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "caption_ids"
    )
  }

  query <- list(
    part = paste(part, collapse = ","),
    videoId = video_id,
    id = if (is.null(caption_ids)) NULL else paste(caption_ids, collapse = ",")
  )
  response <- tuber_GET("captions", query = query, auth = "token", ...)
  items <- response$items %||% list()

  if (!simplify) {
    return(add_tuber_attributes(
      response,
      function_name = "list_captions",
      results_found = length(items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(items, function(item) {
    snippet <- item$snippet %||% list()
    data.frame(
      caption_id = item$id %||% NA_character_,
      video_id = snippet$videoId %||% NA_character_,
      last_updated = snippet$lastUpdated %||% NA_character_,
      track_kind = snippet$trackKind %||% NA_character_,
      language = snippet$language %||% NA_character_,
      name = snippet$name %||% NA_character_,
      audio_track_type = snippet$audioTrackType %||% NA_character_,
      is_cc = snippet$isCC %||% NA,
      is_large = snippet$isLarge %||% NA,
      is_easy_reader = snippet$isEasyReader %||% NA,
      is_draft = snippet$isDraft %||% NA,
      is_auto_synced = snippet$isAutoSynced %||% NA,
      status = snippet$status %||% NA_character_,
      failure_reason = snippet$failureReason %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })

  add_tuber_attributes(
    result,
    function_name = "list_captions",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
