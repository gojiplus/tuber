#' List reasons that can be used to report abusive videos
#'
#' @param part  Caption resource requested. Required. Comma separated list of
#' one or more of the
#' following: \code{id, snippet}. e.g., \code{"id, snippet"}, \code{"id"}, etc.
#'  Default: \code{snippet}.
#' @param hl  Language used for text values. Optional. Default is \code{en-US}.
#'  For other allowed language codes, see \code{\link{list_langs}}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return
#'
#' If no results, empty data.frame returned
#' If part requested = "id, snippet" or "snippet",
#' \code{data.frame} with 4 columns: \code{etag, id, label, secReasons}
#' If part requested = "id", data.frame with 2 columns: \code{etag, id}
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videoAbuseReportReasons/list}
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_abuse_report_reasons()
#' list_abuse_report_reasons(part="id")
#' list_abuse_report_reasons(part="snippet")
#' }

list_abuse_report_reasons <- function(part = "id, snippet", hl = "en-US", ...) {

  if (!is.character(part)) stop("Provide a valid value for part.")

  querylist <- list(part = part)

  res <- tuber_GET("videoAbuseReportReasons", querylist, ...)

  resdf <- data.frame()

  if (length(res$items) != 0) {

    if (part == "id, snippet" | part == "snippet") {
      simple_res  <- lapply(res$items, function(x) c(etag = x$etag, id = x$id,
        label = x$snippet$label,
        secReasons = paste(unlist(x$snippet$secondaryReasons), collapse = ",")))
      resdf       <- ldply(simple_res, rbind)
    }

    if (part == "id") {
      simple_res  <- lapply(res$items, function(x) c(etag = x$etag, id = x$id))
      resdf       <- ldply(simple_res, rbind)
    }
  }

  # Cat total results
  cat("Total Number of Reasons:", length(res$items), "\n")

  resdf
}
