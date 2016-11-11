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
#' @return data.frame with 6 columns: \code{region_code, channelId, title, assignable, etag, id}
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videoCategories/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' list_videocats(c(region_code = "JP"))
#' list_videocats() # Will throw an error asking for a valid filter with valid region_code
#' }

list_videocats <- function (filter = NULL, ...) {

	if (!is.character(filter)) stop("Specify by a valid filter with a valid region code.")

	translate_filter   <- c(category_id = 'id', region_code = 'regionCode')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	names(filter)      <- yt_filter_name

	if (sum(is.na(names(filter)) > 0 )) stop("Filter can only have region_code or category_id.")

	querylist <- c(list(part="snippet"), filter)

	res <- tuber_GET("videoCategories", querylist, ...)

	# Cat total results
	cat("Total Number of Categories:", length(res$items), "\n")

	resdf <- read.table(text = "", 
    					 col.names = c("region_code", "channelId", "title", "assignable", "etag", "id"))

	if (length(res$items) != 0) {
	
		simple_res  <- lapply(res$items, function(x) c(unlist(x$snippet), etag=x$etag, id=x$id))
		resdf       <- as.data.frame(cbind(region_code = filter["regionCode"], do.call(rbind, simple_res)))
	
	} else {

		resdf[1, "region_code"] <- filter["regionCode"]
	}

	resdf
}
