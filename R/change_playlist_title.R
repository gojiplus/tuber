#' Change a Playlist Title
#'
#' Changes a playlist title without deleting the existing description or
#' default language. YouTube replaces every mutable property in the `snippet`
#' part during an update, so this function retrieves and preserves the other
#' snippet properties first.
#'
#' @param playlist_id YouTube playlist ID.
#' @param new_title New playlist title.
#' @param on_behalf_of_content_owner Optional YouTube content-owner ID. This is
#'   only available to authorized YouTube content partners.
#' @param ... Additional arguments passed to [list_playlists()] and
#'   [tuber_PUT()].
#'
#' @return The updated playlist resource.
#' @export
#' @references
#' <https://developers.google.com/youtube/v3/docs/playlists/update>
#' @examples
#' \dontrun{
#' change_playlist_title("PLAYLIST_ID", "New Playlist Title")
#' }
change_playlist_title <- function(playlist_id,
                                  new_title,
                                  on_behalf_of_content_owner = NULL,
                                  ...) {
  assert_string(playlist_id, min.chars = 1, .var.name = "playlist_id")
  assert_string(new_title, min.chars = 1, .var.name = "new_title")
  if (!is.null(on_behalf_of_content_owner)) {
    assert_string(
      on_behalf_of_content_owner,
      min.chars = 1,
      .var.name = "on_behalf_of_content_owner"
    )
  }

  current <- list_playlists(
    playlist_ids = playlist_id,
    part = "snippet",
    simplify = FALSE,
    auth = "token",
    ...
  )
  if (length(current$items %||% list()) == 0) {
    abort(
      "Playlist was not found or is not accessible.",
      playlist_id = playlist_id,
      class = "tuber_playlist_not_found"
    )
  }

  old_snippet <- current$items[[1]]$snippet %||% list()
  snippet <- list(
    title = new_title,
    description = old_snippet$description %||% ""
  )
  if (!is.null(old_snippet$defaultLanguage)) {
    snippet$defaultLanguage <- old_snippet$defaultLanguage
  }

  query <- list(part = "snippet")
  if (!is.null(on_behalf_of_content_owner)) {
    query$onBehalfOfContentOwner <- on_behalf_of_content_owner
  }
  tuber_PUT(
    "playlists",
    query = query,
    body = list(id = playlist_id, snippet = snippet),
    ...
  )
}
