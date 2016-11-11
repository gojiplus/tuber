#' Get List of categories that can be associated with YouTube channels
#' 
#' 
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector: 
#' \code{region_code}: Character. Required. Has to be a ISO 3166-1 alpha-2 code (see \url{https://www.iso.org/obp/ui/#search})
#' \code{category_id}: YouTube channel category ID
#' 
#' @param hl  Language used for text values. Optional. Default is \code{en-US}. For other allowed language codes, see \code{\link{list_langs}}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return data.frame with 4 columns: \code{channelId, title, etag, id}
#' 
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' list_guidecats(c(region_code = "JP"))
#' }

list_guidecats <- function (filter=NULL, hl = NULL, ...) {

	if ( length(filter) != 1) stop("filter must be a vector of length 1.")

	translate_filter   <- c(category_id = 'id', region_code = 'regionCode')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	if (!is.null(filter)) names(filter)      <- yt_filter_name

	querylist <- list(part="snippet", hl = NULL)
    if (!is.null(filter)) querylist <- c(querylist, filter)

	res <- tuber_GET("guideCategories", querylist, ...)

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
