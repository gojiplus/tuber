#' List reasons that can be used to report abusive videos
#' 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'  
#' @return data.frame with 3 columns: etag, label, secReasons
#' 
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videoAbuseReportReasons/list}
#' @examples
#' \dontrun{
#' list_abuse_report_reasons()
#' }

list_abuse_report_reasons <- function (...) {

	querylist <- list(part="snippet")

	res <- tuber_GET("videoAbuseReportReasons", querylist, ...)

	resdf <- NA

	if (length(res$items) != 0) {
		simple_res  <-  lapply(res$items, function(x) c(etag=x$etag, label=x$snippet$label, secReasons=paste(unlist(x$snippet$secondaryReasons), collapse=",")))
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Number of Reasons:", length(res$items), "\n")

	return(invisible(resdf))
}
