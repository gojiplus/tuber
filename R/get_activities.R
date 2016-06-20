#' Get Channel Activity
#' 
#' Returns a list of channel activity events that match the request criteria. 
#' 
#' @param channel_id id of the channel; required; no default
#' @param part specify which part do you want. It can only be one of the three: contentDetails, id, snippet. Default is snippet.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/activities/list}
#' @examples
#' \dontrun{
#' get_activities(channel_id="UCRw8bIz2wMLmfgAgWm903cA")
#' }

get_activities <- function (channel_id=NULL, part="snippet", ...) {

	
	if (is.null(channel_id)) stop("Must specify a channel_id")

	querylist <- list(part=part, channelId=channel_id)

	res <- tuber_GET("activities", querylist, ...)
 
 	res
}
