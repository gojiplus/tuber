#' List Content Regions That YouTube Currently Supports
#' 
#' 
#' @param hl  Language used for text values. Optional. Default is \code{en-US}. For other allowed language codes, see \code{\link{list_langs}}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return data.frame with 3 columns: 
#' \code{gl} (two letter abbreviation), \code{name} (of the region), \code{etag}
#' 
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nRegions/list}
#'
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' list_regions()
#' }

list_regions <- function (hl = NULL, ...) {

  querylist <- list(part = "snippet")

  res <- tuber_GET("i18nRegions", querylist, ...)

  resdf <- read.table(text = "", col.names = c("gl", "name", "etag"))

  # Cat total results
  cat("Total Number of Content Regions:", length(res$items), "\n")

  if (length(res$items) != 0) {
    simple_res  <- lapply(res$items, function(x) c(unlist(x$snippet),
                          etag = x$etag))
    resdf       <- ldply(simple_res, rbind)
  }

  resdf
}
