#' Delete a Playlist
#'
#' @param id   String. Required. id of the playlist that is to be deleted
#' @param \dots Additional arguments passed to \code{\link{tuber_DELETE}}.
#'
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/delete}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' delete_playlists(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }

delete_playlists <- function(id = NULL, ...) {

  if (!is.character(id)) {
    stop("Must specify a valid id.")
  }

  querylist <- list(id = id)
  raw_res <- tuber_DELETE("playlists", query = querylist, ...)

  raw_res
}
