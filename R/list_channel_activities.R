#' List Channel Activity
#' 
#' Returns a list of channel activity events that match the request criteria. 
#' 
#' @param channel_id id of the channel; required; no default
#' @param part specify which part do you want. It can only be one of the three: contentDetails, id, snippet. Default is snippet.
#' @param max_results maximum number of items that should be returned, integer, can be between 0 and 50, default is 50
#' @param page_token specific page in the result set that should be returned, optional
#' @param published_after activity after a particular date, time; datetime in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format, optional
#' @param published_before activity before a particular date, time; datetime in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format, optional
#' @param region_code  ISO 3166-1 alpha-2 country code, optional, see also \link{\code{list_regions}}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return named list
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/activities/list}
#' @examples
#' \dontrun{
#' list_channel_activities(channel_id="UCRw8bIz2wMLmfgAgWm903cA")
#' list_channel_activities(channel_id="UCRw8bIz2wMLmfgAgWm903cA", regionCode="US")
#' }

list_channel_activities <- function (channel_id=NULL, part="snippet", max_results = 50, page_token = NULL, published_after = NULL, published_before = NULL, region_code = NULL, ...) {

	
	if (is.null(channel_id)) stop("Must specify a channel_id")

	querylist <- list(part=part, channelId=channel_id, maxResults = max_results, pageToken = page_token, publishedAfter = published_after, publishedBefore = published_before, regionCode = region_code)

	res <- tuber_GET("activities", querylist, ...)
 
 	res
}
