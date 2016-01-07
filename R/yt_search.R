#' Search YouTube
#'
#' @param term search term; required; no default
#' @param maxResults Numeric. 0 to 50. Acceptable values are 0 to 50, inclusive.
#' 
#' @return data.frame with 13 elements - kind, etag, id.kind, id.videoId, snippet.publishedAt, snippet.channelId, snippet.title, snippet.description, 
#' snippet.thumbnails.default.url, snippet.thumbnails.medium.url, snippet.thumbnails.high.url, snippet.channelTitle, snippet.liveBroadcastContent
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' @examples
#' \dontrun{
#' yt_search(term="Barack Obama")
#' }

yt_search <- function (term=NULL, maxResults=5) {

	if (is.null(term)) stop("Must specify a search term")
	if (maxResults < 0 | maxResults > 50) stop("maxResults only takes a value between 0 and 50")
	
	yt_check_token()

	# For queries with spaces
	term = paste0(unlist(strsplit(term, " ")), collapse="%20")

	querylist <- list(part="snippet", q = term, maxResults=maxResults)

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

	
		