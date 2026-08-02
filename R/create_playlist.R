#' Create New Playlist
#'
#' @param title string; Required. The title of the playlist.
#' @param description string; Optional. The description of the playlist.
#' @param status string; Optional. Default: 'public'. Can be one of: 'private', 'public', or 'unlisted'.
#' @param ... Additional arguments passed to \code{\link{tuber_POST}}.
#'
#' @return The created playlist's details.
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/insert}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' create_playlist(title = "My New Playlist", description = "This is a test playlist.")
#' }
create_playlist <- function(title, description = "", status = "public", ...) {
  # Modern validation using checkmate
  assert_character(title, len = 1, min.chars = 1, .var.name = "title")
  assert_character(description, len = 1, .var.name = "description")
  assert_choice(status, c("private", "public", "unlisted"), .var.name = "status")

  # Prepare the request body
  body <- list(
    snippet = list(title = title, description = description),
    status = list(privacyStatus = status)
  )

  # Make the POST request using tuber_POST_json
  raw_res <- tuber_POST_json(path = "playlists", query = list(part = "snippet,status"), body = body, ...)

  # Return the response
  return(raw_res)
}
