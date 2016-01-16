#' List Content Regions That Youtube Currently Supports
#' 
#' @return data.frame with 2 columns: gl (two letter abbreviation), name (of the region)
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nRegions/list}
#' @examples
#' \dontrun{
#' yt_list_regions()
#' }

yt_list_regions <- function () {

	querylist <- list(part="snippet")

	res <- tuber_GET("i18nRegions", querylist)

	resdf <- NA

	if (length(res$items) != 0) {
		simple_res  <- lapply(res$items, function(x) x$snippet)
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Number of Content Regions:", length(res$items), "\n")

	return(invisible(resdf))
}
