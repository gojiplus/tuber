#' Search YouTube by Topic
#' It uses the Freebase list of topics
#'
#' @param topic topic being searched for; required; no default
#' @return a list
#' @export
#' @references \url{http://www.freebase.com/}
#' @examples
#'  \dontrun{yt_topic_search(topic="Barack Obama")}

yt_topic_search <- function (topic=NULL) {

	google_token <- getOption("google_token")
	if (is.null(google_token)) stop("Please set up authorization via yt_oauth()).")

	# For queries with spaces
	topic <- paste0(unlist(strsplit(topic, " ")), collapse="%20")
	req <- GET(paste0("https://www.googleapis.com/freebase/v1/search?query=", topic))
	stop_for_status(req)

	res <- content(req)

	# Cat total results
	cat("Total Number of Hits", res$hits, "\n")

	return(invisible(res))
}
