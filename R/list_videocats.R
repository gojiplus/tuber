#' List of Categories That Can be Associated with Videos
#' 
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector: 
#' \code{region_code}: Character. Required. Has to be a ISO 3166-1 alpha-2 code (see \url{https://www.iso.org/obp/ui/#search})
#' \code{category_id}: video category ID
#'
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return data.frame with 5 columns: \code{channelId, title, assignable, etag, id}
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videoCategories/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' list_videocats(c(region_code = "JP"))
#' }

list_videocats <- function (filter=NULL, ...) {

	translate_filter   <- c(id = 'id', region_code = 'regionCode')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	names(filter)      <- yt_filter_name

	querylist <- list(part="snippet")
    if (is.character(filter)) querylist <- c(querylist, filter)

	res <- tuber_GET("videoCategories", querylist, ...)

	resdf <- NA

	if (length(res$items) != 0) {
		simple_res  <- lapply(res$items, function(x) c(unlist(x$snippet), etag=x$etag, id=x$id))
		resdf       <- as.data.frame(do.call(rbind, simple_res))
	} else {
		resdf <- 0
	}

	# Cat total results
	cat("Total Number of Categories:", length(res$items), "\n")

	resdf
}
