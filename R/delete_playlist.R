#' Delete a Playlist
#'
#' @param playlist_id Playlist ID.
#' @param ... Additional arguments passed to [tuber_DELETE()].
#' @return The empty API response, invisibly.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/delete}
#' @examples
#' \dontrun{
#' delete_playlist("PLAYLIST_ID")
#' }
delete_playlist <- function(playlist_id, ...) {
  assert_string(playlist_id, min.chars = 1, .var.name = "playlist_id")
  tuber_DELETE("playlists", query = list(id = playlist_id), ...)
}
