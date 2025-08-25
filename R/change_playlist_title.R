#' Change the title of a YouTube playlist.
#'
#' This function updates the title of an existing YouTube playlist using the YouTube Data API.
#'
#' @param playlist_id A character string specifying the ID of the playlist you want to update.
#' @param new_title A character string specifying the new title for the playlist.
#'
#' @return A list containing the server response after the update attempt.
#' @export
#'
#' @examples
#' \dontrun{
#' change_playlist_title(playlist_id = "YourPlaylistID", new_title = "New Playlist Title")
#' }
#'

change_playlist_title <- function(playlist_id, new_title) {
  # Check for a valid token
  yt_check_token()

  # Define the body for the PUT request
  body <- list(
    id = playlist_id,
    snippet = list(title = new_title)
  )

  body_json <- jsonlite::toJSON(body, auto_unbox = TRUE)

  # Use the existing tuber infrastructure to send the PUT request
  req <- httr::PUT(
    url = "https://www.googleapis.com/youtube/v3/playlists",
    query = list(key = getOption("google_key"), part = "snippet"),
    config = httr::config(token = getOption("google_token")),
    body = body_json,
    httr::add_headers(
      `Accept` = "application/json",
      `Content-Type` = "application/json"
    )
  )

  # Check for errors
  tuber_check(req)

  # Extract and return the content
  return(httr::content(req))
}

# Example usage:
# change_playlist_title(playlist_id = "PLOfOyOpiu5saim7DsJmz61uCf8igQiTpF", new_title = "Lil' Casey's Top 40 Countdown 2023-09-29")
