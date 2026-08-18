#' Download a Caption Track
#'
#' Downloads one caption track in its original format and language unless a
#' translation language or output format is requested. YouTube requires OAuth
#' authorization and permission to access the video's captions.
#'
#' @param caption_id Caption-track ID returned by [list_captions()].
#' @param language Optional translation language code.
#' @param format Optional output format: `"sbv"`, `"scc"`, `"srt"`,
#' `"ttml"`, or `"vtt"`.
#' @param as_raw If `TRUE`, return a raw vector; otherwise return one character
#' string.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A raw vector when `as_raw = TRUE`; otherwise a character scalar.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/captions/download}
#' @examples
#' \dontrun{
#' download_caption("y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }
download_caption <- function(caption_id,
                             language = NULL,
                             format = NULL,
                             as_raw = TRUE,
                             ...) {
  assert_string(caption_id, min.chars = 1, .var.name = "caption_id")
  assert_flag(as_raw, .var.name = "as_raw")
  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
  }
  if (!is.null(format)) {
    assert_choice(format, c("sbv", "scc", "srt", "ttml", "vtt"), .var.name = "format")
  }

  raw_result <- tryCatch(
    tuber_GET(
      paste0("captions/", caption_id),
      query = list(tlang = language, tfmt = format),
      auth = "token",
      use_cache = FALSE,
      ...
    ),
    error = function(error) {
      abort(
        "Unable to download caption track.",
        caption_id = caption_id,
        parent = error,
        class = "tuber_caption_download_error"
      )
    }
  )

  if (as_raw) raw_result else rawToChar(raw_result)
}
