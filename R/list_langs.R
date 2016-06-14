#' List Languages That Youtube Currently Supports
#' 
#' @return data.frame with 3 columns: hl (two letter abbreviation), name (of the language), etag
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nLanguages/list}
#' @examples
#' \dontrun{
#' list_langs()
#' }

list_langs <- function (...) {

	querylist <- list(part="snippet")

	res <- tuber_GET("i18nLanguages", querylist)

	resdf <- NA

	if (length(res$items) != 0) {
		simple_res  <- lapply(res$items, function(x) c(unlist(x$snippet), etag=x$etag))
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Number of Languages:", length(res$items), "\n")

	return(invisible(resdf))
}
