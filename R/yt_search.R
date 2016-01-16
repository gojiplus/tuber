#' Search YouTube
#' 
#' Search for videos, channels and playlists. (By default, the function searches for videos.)
#' 
#' @param term Character. Search term; required; no default
#' @param maxResults Numeric. 0 to 50. Acceptable values are 0 to 50, inclusive. 
#' Search results are constrained to a maximum of 500 videos if type is video and we have a value of ChannelId.
#' @param channelId Character. Only return search results from this channel; Optional.
#' @param channelType Character. Optional. Takes one of two values: 'any' or 'show'. Default is 'any'
#' @param eventType Character. Optional. Takes one of three values: `completed', 'live' or 'upcoming'
#' @param location  Character.  Optional. Latitude and Longitude within parentheses, e.g. "(37.42307,-122.08427)"
#' @param locationRadius Character.  Optional. e.g. "1500m", "5km", "10000ft", "0.75mi"
#' @param publishedAfter Character. Optional. RFC 339 Format. For instance, "1970-01-01T00:00:00Z"
#' @param publishedBefore Character. Optional. RFC 339 Format. For instance, "1970-01-01T00:00:00Z"
#' @param type Character. Optional. Takes one of three values: 'video', 'channel', or 'playlist'
#' @param videoCaption Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'closedCaption', 'none'. Type must be set to video.
#' @param videoType Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'episode' (return episode of shows), 'movie' (return movies)
#' @param videoSyndicated Character. Optional. Takes one of two values: 'any' (return all videos; Default), 'true' (return only syndicated videos)
#' @param videoDefinition Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'high' and 'standard'
#' @param videoLicense Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'creativeCommon' (return videos with Creative Commons 
#' license), 'youtube' (return videos with standard YouTube license).
#' 
#' @return data.frame with 13 elements - kind, etag, id.kind, id.videoId, snippet.publishedAt, snippet.channelId, snippet.title, snippet.description, 
#' snippet.thumbnails.default.url, snippet.thumbnails.medium.url, snippet.thumbnails.high.url, snippet.channelTitle, snippet.liveBroadcastContent
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' @examples
#' \dontrun{
#' yt_search(term="Barack Obama")
#' }

yt_search <- function (term=NULL, maxResults=5, channelId= NULL, channelType=NULL, type="video", eventType=NULL, location= NULL, locationRadius=NULL, 
	publishedAfter=NULL, publishedBefore=NULL, videoDefinition = "any", videoCaption="any", videoLicense="any", videoSyndicated="any", videoType="any") {

	if (is.null(term)) stop("Must specify a search term")
	if (maxResults < 0 | maxResults > 50) stop("maxResults only takes a value between 0 and 50")
	if (!(videoLicense %in% c("any", "creativeCommon", "youtube"))) stop("videoLicense can only take values: any, creativeCommon, or youtube")
	if (!(videoSyndicated %in% c("any", "true"))) stop("videoSyndicated can only take values: any or true")
	if (!(videoType %in% c("any", "episode", "movie"))) stop("videoType can only take values: any, episode, or movie")
	if (!is.null(publishedAfter))  if (is.na(as.POSIXct(publishedAfter, format="%Y-%m-%dT%H:%M:%SZ"))) stop("The date is not properly formatted in RFC 339 Format")
	if (!is.null(publishedBefore)) if (is.na(as.POSIXct(publishedBefore, format="%Y-%m-%dT%H:%M:%SZ"))) stop("The date is not properly formatted in RFC 339 Format")

	if (any (!is.null(videoCaption), !is.null(videoLicense), !is.null(videoDefinition), !is.null(videoType), !is.null(videoSyndicated)) & type!="video") stop("Specify type as video.")
	if (type!="video") videoCaption = videoLicense = videoDefinition = videoType = videoSyndicated= NULL

	yt_check_token()

	# For queries with spaces
	term = paste0(unlist(strsplit(term, " ")), collapse="%20")

	querylist <- list(part="snippet", q = term, maxResults=maxResults, channelId=channelId, type=type, channelType=channelType, eventType= eventType, 
		location= location, publishedAfter=publishedAfter, publishedBefore=publishedBefore, videoDefinition = videoDefinition, videoCaption= videoCaption, 
		videoType=videoType, videoSyndicated=videoSyndicated, videoLicense= videoLicense)

	req <- GET("https://www.googleapis.com/youtube/v3/search", query=querylist, config(token = getOption("google_token")))
	stop_for_status(req)
	res <- content(req)
	
	resdf <- NA

	if (res$pageInfo$totalResults != 0) {
		simple_res  <- lapply(res$items, function(x) x$snippet)
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Results", res$pageInfo$totalResults, "\n")

	return(invisible(resdf))
}
