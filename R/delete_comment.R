#' Delete a Comment
#'
#' @param comment_id Comment ID.
#' @param ... Additional arguments passed to [tuber_DELETE()].
#' @return The empty API response, invisibly.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/comments/delete}
#' @examples
#' \dontrun{
#' delete_comment("COMMENT_ID")
#' }
delete_comment <- function(comment_id, ...) {
  assert_string(comment_id, min.chars = 1, .var.name = "comment_id")
  tuber_DELETE("comments", query = list(id = comment_id), ...)
}
