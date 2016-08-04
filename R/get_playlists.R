#' Get Playlists
#' 
#' @param channel_id Character. ID of the channel
#' @param part Required. One of the following: contentDetails, id, localizations, player, snippet, status. Default: contentDetails.
#' @param max_results maximum number of items that should be returned, integer, can be between 0 and 50, default is 50
#' @param page_token specific page in the result set that should be returned, optional
#' @param hl  language that will be used for text values, optional, default is en-US. See also \code{\link{list_langs}}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/list}
#' @examples
#' \dontrun{
#' get_playlists(channel_id="UChTJTbr5kf3hYazJZO-euHg")
#' }

get_playlists <- function (channel_id = NULL, part="contentDetails", max_results=50, hl = NULL, page_token=NULL, ...) {

	yt_check_token()
	
	querylist <- list(channelId = channel_id, part=part, maxResults = max_results, pageToken = page_token, hl = hl)

	res <- tuber_GET("playlists", querylist, ...)
 
 	res

}
