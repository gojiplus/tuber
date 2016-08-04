#' Get Subscriptions
#' 
#' @param channel_id Character. ID of the channel
#' @param part Required. String. A comma separated list of one or more of the following: contentDetails, id, snippet, subscriberSnippet. Default: contentDetails. e.g. "id, snippet", "id", etc.
#' @param max_results Optional. Integer. Maximum number of items that should be returned. Can be between 0 and 50. Default is 50.
#' @param page_token  Optional. String.  Specific page in the result set that should be returned, optional
#' @param for_channel_id  Optional. String. A comma-separated list of channel IDs. Limits response to subscriptions matching those channels.
#' @param order method that will be used to sort resources in the API response. Takes one of the following: alphabetical, relevance, unread
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/list}
#' @examples
#' \dontrun{
#' get_subscriptions(channel_id="UChTJTbr5kf3hYazJZO-euHg")
#' }

get_subscriptions <- function (channel_id = NULL, part="contentDetails", max_results=50, for_channel_id = NULL, order=NULL, page_token=NULL, ...) {

	yt_check_token()
	
	querylist <- list(channelId = channel_id, part=part, maxResults = max_results, pageToken = page_token, order = order, forChannelId = for_channel_id)

	res <- tuber_GET("playlists", querylist, ...)
 
 	res

}
