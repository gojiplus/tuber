#' List Captions for YouTube Video
#'
#' @param video_id ID of the YouTube video
#' @param query Fields for `query` in `GET`
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments to send to \code{\link{tuber_GET}}
#' @return A list containing caption information
#'
#' @examples \dontrun{
#' video_id <- "M7FIvfx5J10"
#' list_captions(video_id)
#' }
list_captions <- function(
  video_id,
  query = NULL,
  auth = "token",
  ...
) {

  # Modern validation using checkmate
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  if (!is.null(query)) {
    assert_list(query, .var.name = "query")
  }

  part <- "id,snippet"

  query <- as.list(query)
  query$part <- part
  query$videoId <- video_id

  # Use centralized tuber_GET instead of direct httr::GET
  res <- tuber_GET("captions", query = query, auth = auth, ...)

  res
}
