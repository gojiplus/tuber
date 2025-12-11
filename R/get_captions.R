#' Get Particular Caption Track
#'
#' For getting captions from the v3 API, you must specify the id resource.
#' Check \code{\link{list_caption_tracks}} for more information.
#' IMPORTANT: This function requires OAuth authentication and you must own the video
#' or have appropriate permissions to access its captions.
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
#' # You must own the video to download captions
#'
#' get_captions(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }

get_captions <- function(id = NULL, lang = "en",
                          format = "sbv", as_raw = TRUE, ...) {

  # Modern validation using checkmate
  assert_character(id, len = 1, min.chars = 1, .var.name = "id")
  assert_character(lang, len = 1, min.chars = 1, .var.name = "lang")
  assert_character(format, len = 1, min.chars = 1, .var.name = "format")
  assert_logical(as_raw, len = 1, .var.name = "as_raw")

  # Check authentication - captions require OAuth token and video ownership
  yt_check_token()

  querylist <- list(tlang = lang, tfmt = format)
  
  # Enhanced error handling for common caption access issues
  raw_res <- tryCatch({
    tuber_GET(paste0("captions", "/", id), query = querylist, ...)
  }, error = function(e) {
    if (grepl("403", e$message)) {
      abort("HTTP 403: Access denied for caption ID",
            caption_id = id,
            help = c("This usually means:", 
                     "(1) You don't own this video",
                     "(2) Video has no captions", 
                     "(3) Captions are auto-generated and not downloadable",
                     "Only video owners can download captions via the API"),
            class = "tuber_caption_access_denied")
    } else {
      abort("Error retrieving captions",
            caption_id = id,
            original_error = e$message,
            class = "tuber_caption_fetch_error")
    }
  })

  if (!as_raw) {
    raw_res <- rawToChar(raw_res)
    raw_res <- strsplit(raw_res, split = "\n")[[1]]
  }
  raw_res
}
