#' Set Video Thumbnail
#'
#' Uploads a custom video thumbnail to YouTube and sets it for a video.
#' Requires OAuth 2.0 authentication.
#'
#' @param video_id Character. ID of the video to set the thumbnail for.
#' @param file Character. Path to the thumbnail image file (JPG or PNG, max 2MB).
#' @param \dots Additional arguments passed to \code{\link[httr]{POST}}.
#'
#' @return A list containing the response from the API.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/thumbnails/set}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' set_video_thumbnail(video_id = "yJXTXN4xrI8", file = "thumbnail.jpg")
#' }
set_video_thumbnail <- function(video_id, file, ...) {
  # Validation
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")

  if (!file.exists(file)) {
    abort("File does not exist",
          file_path = file,
          class = "tuber_file_not_found")
  }

  file_size <- file.info(file)$size
  if (file_size > 2 * 1024 * 1024) {
    warning("Thumbnail file size exceeds 2MB. The upload may fail.")
  }

  yt_check_token()

  url <- "https://www.googleapis.com/upload/youtube/v3/thumbnails/set"

  req <- httr::POST(
    url,
    query = list(videoId = video_id),
    body = httr::upload_file(file),
    config(token = getOption("google_token")),
    ...
  )

  tuber_check(req)

  res <- content(req)
  list(request = req, content = res)
}
