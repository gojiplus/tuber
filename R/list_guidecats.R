#' Get list of categories that can be associated with YouTube channels
#'
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{region_code}: Character. Required. Has to be a ISO 3166-1 alpha-2 code
#'  (see \url{https://www.iso.org/obp/ui/#search})
#' \code{category_id}: YouTube channel category ID
#'
#' @param hl  Language used for text values. Optional. Default is \code{en-US}.
#'  For other allowed language codes, see \code{\link{list_langs}}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return data.frame with 5 columns: \code{region_code, channelId, title,
#' etag, id}
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/guideCategories/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_guidecats(c(region_code = "JP"))
#' }

list_guidecats <- function(filter = NULL, hl = NULL, ...) {

  if (!is.character(filter)) {
    stop("filter must be a character vector of length 1.")
  }

  translate_filter   <- c(category_id = "id", region_code = "regionCode")
  yt_filter_name     <- as.vector(translate_filter[match(names(filter),
                                                      names(translate_filter))])
  names(filter)      <- yt_filter_name

  if (sum(is.na(names(filter)) > 0)) {
    stop("Filter can only have region_code or category_id.")
  }

  querylist <- c(list(part = "snippet", hl = hl), filter)

  res <- tuber_GET("guideCategories", querylist, ...)

  resdf <- read.table(text = "",
               col.names = c("region_code", "channelId", "title", "etag", "id"))

  # Cat total results
  cat("Total Number of Categories:", length(res$items), "\n")

  if (length(res$items) > 0) {

    simple_res  <- lapply(res$items, function(x) c(unlist(x$snippet),
                                                      etag = x$etag, id = x$id))

    resdf       <- as.data.frame(cbind(region_code = filter["regionCode"],
                                                    do.call(rbind, simple_res)))
  } else {

    resdf[1, "region_code"] <- filter["regionCode"]
  }

  resdf
}
