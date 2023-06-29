#' Delete a Particular Caption Track
#'
#' @param id   String. Required. id of the caption track that is being retrieved
#' @param \dots Additional arguments passed to \code{\link{tuber_DELETE}}.
#'
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/captions/delete}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' delete_captions(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }

delete_captions <- function(id = NULL, ...) {

  if (missing(id) || !is.character(id)) {
    stop("Must specify a valid ID.")
  }

  querylist <- list(id = id)
  raw_res <- tuber_DELETE("captions", query = querylist, ...)

  raw_res
}
