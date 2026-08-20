#' Delete a Playlist Item
#'
#' @param playlist_item_id Playlist-item ID, not the video ID.
#' @param ... Additional arguments passed to [tuber_DELETE()].
#' @return The empty API response, invisibly.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlistItems/delete}
#' @examples
#' \dontrun{
#' delete_playlist_item("PLAYLIST_ITEM_ID")
#' }
delete_playlist_item <- function(playlist_item_id, ...) {
  assert_string(playlist_item_id, min.chars = 1, .var.name = "playlist_item_id")
  tuber_DELETE("playlistItems", query = list(id = playlist_item_id), ...)
}
