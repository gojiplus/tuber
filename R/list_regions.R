#' List Content Regions That Youtube Currently Supports
#' 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' @param hl  Language used for text values. Optional. Default is \code{en-US}. For other allowed language codes, see \code{\link{list_langs}}.
#' 
#' @return data.frame with 3 columns: gl (two letter abbreviation), name (of the region), etag
#' 
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nRegions/list}
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
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

	resdf
}
