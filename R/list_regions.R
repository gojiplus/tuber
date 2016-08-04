#' List Content Regions That Youtube Currently Supports
#' 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' @param hl  language that will be used for text values, optional, default is en-US. See also \code{\link{list_langs}}
#' 
#' @return data.frame with 3 columns: gl (two letter abbreviation), name (of the region), etag
#' 
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nRegions/list}
#' @examples
#' \dontrun{
#' list_regions()
#' }

list_regions <- function (hl = NULL, ...) {

	querylist <- list(part="snippet")

	res <- tuber_GET("i18nRegions", querylist, ...)

	resdf <- NA

	if (length(res$items) != 0) {
		simple_res  <- lapply(res$items, function(x) c(unlist(x$snippet), etag=x$etag))
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Number of Content Regions:", length(res$items), "\n")

	return(invisible(resdf))
}
