#' List Channel Activity
#' 
#' Returns a list of channel events that match the request criteria. 
#' 
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector: 
#' \code{channel_id}: ID of the channel. Required. No default.
#' 
#' @param part specify which part do you want. It can only be one of the three: \code{contentDetails, id, snippet}. Default is \code{snippet}.
#' @param max_results Maximum number of items that should be returned. Integer. Optional. Can be between 0 and 50. Default is 50.
#' @param page_token specific page in the result set that should be returned, optional
#' @param published_after Character. Optional. RFC 339 Format. For instance, "1970-01-01T00:00:00Z"
#' @param published_before Character. Optional. RFC 339 Format. For instance, "1970-01-01T00:00:00Z"
#' @param region_code  ISO 3166-1 alpha-2 country code, optional, see also \code{\link{list_regions}}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return named list
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/activities/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' list_channel_activities(filter = c(channel_id="UCRw8bIz2wMLmfgAgWm903cA"))
#' list_channel_activities(filter = c(channel_id="UCRw8bIz2wMLmfgAgWm903cA", regionCode="US"))
#' }

list_channel_activities <- function (filter=NULL, part="snippet", max_results = 50, page_token = NULL, published_after = NULL, published_before = NULL, region_code = NULL, ...) {

	if (max_results < 0 | max_results > 50) stop("max_results only takes a value between 0 and 50")

	if (is.character(published_after))  if (is.na(as.POSIXct(published_after, format="%Y-%m-%dT%H:%M:%SZ"))) stop("The date is not properly formatted in RFC 339 Format")
	if (is.character(published_before)) if (is.na(as.POSIXct(published_before, format="%Y-%m-%dT%H:%M:%SZ"))) stop("The date is not properly formatted in RFC 339 Format")

	if (!(names(filter) %in% c("channel_id"))) stop("filter can only take one of values: channel_id.")
	if ( length(filter) != 1) stop("filter must be a vector of length 1.")

	translate_filter   <- c(channel_id = 'channelId')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	names(filter)      <- yt_filter_name

	querylist <- list(part=part, maxResults = max_results, pageToken = page_token, publishedAfter = published_after, publishedBefore = published_before, regionCode = region_code)
	querylist <- c(querylist, filter)

	res <- tuber_GET("activities", querylist, ...)
 
 	res
}
