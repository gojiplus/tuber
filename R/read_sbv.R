#' Read SBV file
#'
#' @param file The file name of the \code{sbv} file
#'
#' @return A \code{data.frame} with start/stop times and the text
#' @export
#' @importFrom hms as_hms
#'
#' @examples
#' if (yt_authorized()){
#' vids <- list_my_videos()
#' res <- list_caption_tracks(video_id = vids$contentDetails.videoId[1])
#' cap <- get_captions(id = res$id, as_raw = FALSE)
#' tfile <- tempfile(fileext = ".sbv")
#' writeLines(cap, tfile)
#' x <- read_sbv(tfile)
#' if (requireNamespace("hms", quietly = TRUE)) {
#'   x$start <- hms::as_hms(x$start)
#'   x$stop <- hms::as_hms(x$stop)
#' }
#' }
read_sbv <- function(file) {
  # Modern validation using checkmate
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")
  
  if (!file.exists(file)) {
    abort("SBV file does not exist", 
          file_path = file,
          class = "tuber_file_not_found")
  }
  
  x <- readLines(file)
  x <- matrix(x, ncol = 3, byrow = TRUE)
  colnames(x) <- c("time", "text", "empty")
  x <- as.data.frame(x, stringsAsFactors = FALSE)
  if (!all(x$empty %in% "")) {
    warn("Something seems off - results may be wrong",
         file_path = file,
         class = "tuber_sbv_parse_warning")
  }
  x$empty <- NULL
  times <- do.call(rbind, lapply(strsplit(x$time, ","), c))
  colnames(times) <- c("start", "stop")
  times <- as.data.frame(times, stringsAsFactors = FALSE)
  times$time <- x$time
  x <- merge(x, times, all.x = TRUE, by = "time")
  x$time <- NULL
  # x$start <- hms::as_hms(x$start)
  # x$stop <- hms::as_hms(x$stop)
  return(x)
}
