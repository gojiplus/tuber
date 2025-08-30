#' Change the title of a YouTube playlist.
#'
#' This function updates the title of an existing YouTube playlist using the YouTube Data API.
#'
#' @param playlist_id A character string specifying the ID of the playlist you want to update.
#' @param new_title A character string specifying the new title for the playlist.
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#'
#' @return A list containing the server response after the update attempt.
#' @export
#'
#' @examples
#' \dontrun{
#' change_playlist_title(playlist_id = "YourPlaylistID", new_title = "New Playlist Title")
#' }
#'

change_playlist_title <- function(playlist_id, new_title, auth = "token") {
  # Define the body for the PUT request
  body <- list(
    id = playlist_id,
    snippet = list(title = new_title)
  )

  query <- list(part = "snippet")

  # Use the centralized tuber_PUT function
  res <- tuber_PUT("playlists", query = query, body = body, auth = auth)

  return(res)
}

# Example usage:
# change_playlist_title(playlist_id = "PLOfOyOpiu5saim7DsJmz61uCf8igQiTpF", new_title = "Lil' Casey's Top 40 Countdown 2023-09-29")
