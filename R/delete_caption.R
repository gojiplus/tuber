#' Delete a Caption Track
#'
#' @param caption_id Caption-track ID.
#' @param ... Additional arguments passed to [tuber_DELETE()].
#' @return The empty API response, invisibly.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/captions/delete}
#' @examples
#' \dontrun{
#' delete_caption("y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }
delete_caption <- function(caption_id, ...) {
  assert_string(caption_id, min.chars = 1, .var.name = "caption_id")
  tuber_DELETE("captions", query = list(id = caption_id), ...)
}
