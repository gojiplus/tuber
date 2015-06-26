#' Search YouTube
#'
#' @param term search term; required; no default
#' @return data.frame with 13 elements - kind, etag, id.kind, id.videoId, snippet.publishedAt, snippet.channelId, snippet.title, snippet.description, 
#' snippet.thumbnails.default.url, snippet.thumbnails.medium.url, snippet.thumbnails.high.url, snippet.channelTitle, snippet.liveBroadcastContent
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#' yt_search(term="Barack Obama")

yt_search <- function (term=NULL) {

	google_token <- getOption("google_token")
	if (is.null(google_token)) stop("Please set up authorization via yt_oauth()).")

	# For queries with spaces
	term <- paste0(unlist(strsplit(term, " ")), collapse="%20")
	req <- httr::GET(paste0("https://www.googleapis.com/youtube/v3/search?part=snippet&q=", term), config(token = google_token))
	httr::stop_for_status(req)

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
