#' Search YouTube by Topic
#' It uses the Freebase list of topics
#'
#' @param topic topic being searched for; required; no default
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return a list
#' @export
#' @examples
#'  \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' yt_topic_search(topic="Barack Obama")
#' }

yt_topic_search <- function (topic=NULL, ...) {

	.Deprecated("Freebase no longer supported by Google.")

	if (!is.character(topic)) stop("Must specify a topic")

	yt_check_token()

	# For queries with spaces
	topic <- paste0(unlist(strsplit(topic, " ")), collapse="%20")
	querylist = list(query=topic)

	req <- GET("https://www.googleapis.com/freebase/v1/search", query=querylist, config(token =  getOption("google_token")), ...)
	stop_for_status(req)

	res <- content(req)

	# Cat total results
	cat("Total Number of Hits", res$hits, "\n")

	return(invisible(res))
}
