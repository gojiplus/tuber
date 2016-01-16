#' Get Related Videos 
#' 
#' Takes a video id and returns related videos
#' 
#' @param video_id Character. Required. No default.
#' @param maxResults Numeric. 0 to 50. Acceptable values are 0 to 50, inclusive.
#' @param safeSearch Character. Optional. Takes one of three values: 'moderate', 'none' (default) or 'strict'
#' 
#' @return data.frame with 7 columns: publishedAt, channelId, title, description, thumbnails, channelTitle, liveBroadcastContent
#' 
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' @examples
#' \dontrun{
#' yt_get_related_videos(video_id="yJXTXN4xrI8")
#' }

yt_get_related_videos <- function (video_id=NULL, maxResults=5, safeSearch='none') {

	if (is.null(video_id)) stop("Must specify a video ID")
	if (maxResults < 0 | maxResults > 50) stop("maxResults only takes a value between 0 and 50")
	
	yt_check_token()

	# For queries with spaces
	term = paste0(unlist(strsplit(term, " ")), collapse="%20", safeSearch = safeSearch)

	querylist <- list(part="snippet", relatedToVideoId = video_id, type="video", maxResults=maxResults)

	res <- tuber_GET("search", querylist)
	
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

	
		