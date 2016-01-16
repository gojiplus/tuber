#' List of Categories That Can be Associated with Videos
#' 
#' @param regionCode Character. Required. Has to be a ISO 3166-1 alpha-2 code (see \url{https://www.iso.org/obp/ui/#search}).
#' 
#' @return data.frame with 3 columns - channelId, title, assignable
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' @examples
#' \dontrun{
#' yt_list_videocats("JP")
#' }

yt_list_videocats <- function (regionCode=NULL) {

	if (is.null(regionCode)) stop("Must specify a regionCode")

	querylist <- list(part="snippet", regionCode=regionCode)

	res <- tuber_GET("videoCategories", querylist)

	resdf <- NA

	if (length(res$items) != 0) {
		simple_res  <- lapply(res$items, function(x) x$snippet)
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Number of Categories", length(res$items), "\n")

	return(invisible(resdf))
}
