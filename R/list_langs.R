#' List Languages That YouTube Currently Supports
#'
#' @param hl  Language used for text values. Optional. Default is \code{en-US}.
#' For other allowed language codes, see \code{\link{list_langs}}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return data.frame with 3 columns: \code{hl} (two letter abbreviation),
#' \code{name} (of the language), \code{etag}
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nLanguages/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_langs()
#' }

list_langs <- function (hl = NULL, ...) {

  querylist <- list(part = "snippet", hl = hl)

  res <- tuber_GET("i18nLanguages", querylist)

  resdf <- data.frame()

  if (length(res$items) != 0) {
    simple_res  <- lapply(res$items, function(x) c(unlist(x$snippet),
                                                                 etag = x$etag))
    resdf       <- as.data.frame(do.call(rbind, simple_res))
  }

  # Cat total results
  cat("Total Number of Languages:", length(res$items), "\n")

  resdf
}
