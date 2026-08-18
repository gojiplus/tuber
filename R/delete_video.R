#' Delete a Video
#'
#' @param video_id Video ID.
#' @param ... Additional arguments passed to [tuber_DELETE()].
#' @return The empty API response, invisibly.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videos/delete}
#' @examples
#' \dontrun{
#' delete_video("VIDEO_ID")
#' }
delete_video <- function(video_id, ...) {
  assert_string(video_id, min.chars = 1, .var.name = "video_id")
  tuber_DELETE("videos", query = list(id = video_id), ...)
}
