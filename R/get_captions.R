#' Get Particular Caption Track
#'
#' For getting captions from the v3 API, you must specify the id resource.
#' Check \code{\link{list_caption_tracks}} for more information.
#'
#' @param id   String. Required. id of the caption track that is being retrieved
#' @param lang Optional. Default is \code{en}.
#' @param format Optional. Default is \code{sbv}.
#' @param as_raw If \code{FALSE} the captions be converted to a character
#' string versus a raw vector
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return String.
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/captions/download}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_captions(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }

get_captions <- function (id = NULL, lang = "en",
                          format = "sbv", as_raw = TRUE, ...) {

  if ( !is.character(id)) {
    stop("Must specify a valid id.")
  }

  querylist <- list(tlang = lang, tfmt = format)
  raw_res <- tuber_GET(paste0("captions", "/", id), query = querylist, ...)

  if (!as_raw) {
    raw_res <- rawToChar(raw_res)
    raw_res <- strsplit(raw_res, split = "\n")[[1]]
  }
  raw_res
}
