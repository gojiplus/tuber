#' Read SBV file
#'
#' @param file The file name of the \code{sbv} file
#'
#' @return A data frame with one row per caption, in file order, and the
#' columns `text`, `start` and `stop`. A caption that spans several lines
#' keeps its line breaks.
#' @export
#'
#' @examples
#' if (yt_authorized()) {
#'   vids <- list_my_videos()
#'   res <- list_captions(video_id = vids$video_id[[1]])
#'   cap <- download_caption(res$caption_id[[1]], as_raw = FALSE)
#'   tfile <- tempfile(fileext = ".sbv")
#'   writeLines(cap, tfile)
#'   x <- read_sbv(tfile)
#'   if (requireNamespace("hms", quietly = TRUE)) {
#'     x$start <- hms::as_hms(x$start)
#'     x$stop <- hms::as_hms(x$stop)
#'   }
#' }
read_sbv <- function(file) {
  # Modern validation using checkmate
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")

  if (!file.exists(file)) {
    abort("SBV file does not exist",
      file_path = file,
      class = "tuber_file_not_found"
    )
  }

  # Hand-rolled: an SBV file is blank-line-separated blocks, each a
  # "start,stop" line followed by one or more lines of text. On CRAN, srt
  # reads SubRip only; subtools reads SubViewer, which was not tested against
  # YouTube's SBV variant and would not return this function's columns.
  lines <- sub("^\ufeff", "", readLines(file, warn = FALSE, encoding = "UTF-8"))
  blank <- !nzchar(trimws(lines))
  blocks <- unname(split(lines[!blank], cumsum(blank)[!blank]))

  times <- vapply(blocks, function(block) block[[1]], character(1))
  time_range <- "^\\d+:\\d{2}:\\d{2}\\.\\d{3},\\d+:\\d{2}:\\d{2}\\.\\d{3}$"
  malformed <- which(!grepl(time_range, times))
  if (length(malformed) > 0) {
    abort(
      c(
        "This does not look like an SBV file.",
        x = paste0(
          "Caption block ", malformed[[1]], " starts with \"", times[[malformed[[1]]]],
          "\", not a `start,stop` time range."
        )
      ),
      file_path = file,
      class = "tuber_sbv_parse_error"
    )
  }

  split_times <- strsplit(times, ",", fixed = TRUE)
  data.frame(
    text = vapply(blocks, function(block) paste(block[-1], collapse = "\n"), character(1)),
    start = vapply(split_times, function(x) x[[1]], character(1)),
    stop = vapply(split_times, function(x) x[[2]], character(1)),
    stringsAsFactors = FALSE
  )
}
