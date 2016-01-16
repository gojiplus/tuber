#' List Languages That Youtube Currently Supports
#' 
#' @return data.frame with 2 columns: hl (two letter abbreviation), name (of the language)
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nLanguages/list}
#' @examples
#' \dontrun{
#' yt_list_langs()
#' }

yt_list_langs <- function () {

	querylist <- list(part="snippet")

	res <- tuber_GET("i18nLanguages", querylist)

	resdf <- NA

	if (length(res$items) != 0) {
		simple_res  <- lapply(res$items, function(x) x$snippet)
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Number of Languages:", length(res$items), "\n")

	return(invisible(resdf))
}
