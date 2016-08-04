#' Get Playlist Items
#' 
#' @param playlist_id ID of the playlist
#' @param part Required. Comma separated string including one or more of the following: \code{contentDetails, id, snippet, status}. Default: \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned. Integer. Optional. Can be between 0 and 50. Default is 50.
#' @param page_token specific page in the result set that should be returned, optional
#' @param video_id  Optional. request should return only the playlist items that contain the specified video.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/list}
#' @examples
#' \dontrun{
#' get_playlist_items(playlist_id="PLrEnWoR732-CN09YykVof2lxdI3MLOZda")
#' }

get_playlist_items <- function (playlist_id = NULL, part="contentDetails", max_results=50, video_id = NULL, page_token = NULL, ...) {

	if (max_results < 0 | max_results > 50) stop("max_results only takes a value between 0 and 50")

	yt_check_token()
	
	querylist <- list(playlistId = playlist_id, part=part, maxResults = max_results, pageToken = page_token, videoId = video_id)

	res <- tuber_GET("playlistItems", querylist, ...)
 
 	res

}
