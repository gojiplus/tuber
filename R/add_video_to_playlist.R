#' Add Video to Playlist
#'
#' @param playlist_id string; Required. The ID of the playlist.
#' @param video_id string; Required. The ID of the video to add.
#' @param position numeric; Optional. The position of the video in the playlist.
#'   If not provided, the video will be added to the end of the playlist.
#' @param ... Additional arguments passed to \code{\link{tuber_POST_json}}.
#'
#' @return Details of the added video in the playlist.
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlistItems/insert}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' add_video_to_playlist(playlist_id = "YourPlaylistID", video_id = "2_gLD1jarfU")
#' }

add_video_to_playlist <- function(playlist_id, video_id, position = NULL, ...) {

  # Modern validation using checkmate
  assert_character(playlist_id, len = 1, min.chars = 1, .var.name = "playlist_id")
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")
  
  if (!is.null(position)) {
    assert_integerish(position, len = 1, lower = 0, .var.name = "position")
  }

  # Prepare the request body
  if(is.null(position)){
    body <- list(
      snippet = list(
        playlistId = playlist_id,
        resourceId = list(
          kind = "youtube#video",
          videoId = video_id
        )
      )
    )
  } else {
    body <- list(
      snippet = list(
        playlistId = playlist_id,
        position = position,
        resourceId = list(
          kind = "youtube#video",
          videoId = video_id
        )
      )
    )
  }

  # Make the POST request using tuber_POST_json
  raw_res <- tuber_POST_json(path = "playlistItems", query = list(part = "snippet"), body = body, ...)

  # Return the response
  return(raw_res)
}
