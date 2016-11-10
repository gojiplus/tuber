#' Get Related Videos 
#' 
#' Takes a video id and returns related videos
#' 
#' @param video_id Character. Required. No default.
#' @param max_results Maximum number of items that should be returned. Integer. Optional. Can be between 0 and 50. Default is 50.
#' @param safe_search Character. Optional. Takes one of three values: 'moderate', 'none' (default) or 'strict'
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'  
#' @return data.frame with 15 columns: publishedAt, channelId, title, description, 
#' thumbnails.default.url, thumbnails.default.width, thumbnails.default.height, thumbnails.medium.url, 
#' thumbnails.medium.width, thumbnails.medium.height, thumbnails.high.url, thumbnails.high.width, 
#' thumbnails.high.height, channelTitle, liveBroadcastContent
#' 
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' get_related_videos(video_id="yJXTXN4xrI8")
#' }

get_related_videos <- function (video_id=NULL, max_results=50, safe_search='none', ...) {

	if (is.null(video_id)) stop("Must specify a video ID")
	if (max_results < 0 | max_results > 50) stop("max_results only takes a value between 0 and 50")
	
	querylist <- list(part="snippet", relatedToVideoId = video_id, type="video", maxResults=max_results, safeSearch = safe_search)

	res <- tuber_GET("search", querylist, ...)
	
	resdf <- NA

	if (res$pageInfo$totalResults != 0) {
		simple_res  <- lapply(res$items, function(x) unlist(x$snippet))
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- data.frame()
	}

	# Cat total results
	cat("Total Results", res$pageInfo$totalResults, "\n")

	return(invisible(resdf))
}
