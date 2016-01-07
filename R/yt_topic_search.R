#' Search YouTube by Topic
#' It uses the Freebase list of topics
#'
#' @param topic topic being searched for; required; no default
#' @return a list
#' @export
#' @references \url{http://www.freebase.com/}
#' @examples
#'  \dontrun{
#' yt_topic_search(topic="Barack Obama")
#' }

yt_topic_search <- function (topic=NULL) {

	.Deprecated("Freebase no longer supported by Google.")

	if (is.null(topic)) stop("Must specify a topic")

	yt_check_token()

	# For queries with spaces
	topic <- paste0(unlist(strsplit(topic, " ")), collapse="%20")
	querylist = list(query=topic)

	req <- GET("https://www.googleapis.com/freebase/v1/search", query=querylist, config(token =  getOption("google_token")))
	stop_for_status(req)

	res <- content(req)

	# Cat total results
	cat("Total Number of Hits", res$hits, "\n")

	return(invisible(res))
}
