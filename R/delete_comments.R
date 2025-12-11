#' Delete a Particular Comment
#'
#' @param id   String. Required. id of the comment being retrieved
#' @param \dots Additional arguments passed to \code{\link{tuber_DELETE}}.
#'
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/comments/delete}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' delete_comments(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }

delete_comments <- function(id = NULL, ...) {

  # Modern validation using checkmate
  assert_character(id, len = 1, min.chars = 1, .var.name = "id")

  querylist <- list(id = id)
  raw_res <- tuber_DELETE("comments", query = querylist, ...)

  raw_res
}
