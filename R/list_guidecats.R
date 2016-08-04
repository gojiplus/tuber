#' Get List of categories that can be associated with YouTube channels
#' 
#' @param regionCode Character. Required. Has to be a ISO 3166-1 alpha-2 code (see \url{https://www.iso.org/obp/ui/#search})
#' @param hl  Language used for text values. Optional. Default is \code{en-US}. For other allowed language codes, see \code{\link{list_langs}}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return data.frame with 4 columns: channelId, title, etag, id
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' @examples
#' \dontrun{
#' list_guidecats("JP")
#' }

list_guidecats <- function (regionCode=NULL, hl = NULL, ...) {

	if (is.null(regionCode)) stop("Must specify a regionCode")

	querylist <- list(part="snippet", regionCode=regionCode, hl = NULL)

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

	return(invisible(resdf))
}
