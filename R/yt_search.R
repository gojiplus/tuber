#' Search YouTube
#'
#' @param term search term; required; no default
#' 
#' @return data.frame with 13 elements - kind, etag, id.kind, id.videoId, snippet.publishedAt, snippet.channelId, snippet.title, snippet.description, 
#' snippet.thumbnails.default.url, snippet.thumbnails.medium.url, snippet.thumbnails.high.url, snippet.channelTitle, snippet.liveBroadcastContent
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#' \dontrun{
#' yt_search(term="Barack Obama")
#' }

yt_search <- function (term=NULL) {

	if (is.null(term)) stop("Must specify a search term")

	yt_check_token()

	# For queries with spaces
	term = paste0(unlist(strsplit(term, " ")), collapse="%20")
	querylist <- list(part="snippet", q = term)

	req <- GET("https://www.googleapis.com/youtube/v3/search", query=querylist, config(token = getOption("google_token")))
	stop_for_status(req)
	res <- content(req)
	
	resdf <- NA

	if (res$pageInfo$totalResults!=0) {
		col_names <- names(unlist(res$items)[1:13])
		resdf    <- as.data.frame(matrix(unlist(res$items),nrow=5,byrow=TRUE))
		colnames(resdf) <- col_names
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Results", res$pageInfo$totalResults, "\n")

	return(invisible(resdf))
}
