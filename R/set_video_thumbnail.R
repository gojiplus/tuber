#' Set Video Thumbnail
#'
#' Uploads a custom video thumbnail to YouTube and sets it for a video.
#' Requires OAuth 2.0 authentication.
#'
#' @param video_id Character. ID of the video to set the thumbnail for.
#' @param file Character. Path to the thumbnail image file (JPG or PNG, max 2MB).
#' @param \dots Ignored; retained for backward compatibility.
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
      class = "tuber_file_not_found"
    )
  }

  file_size <- file.info(file)$size
  if (file_size > 2 * 1024 * 1024) {
    abort(
      "Thumbnail file exceeds YouTube's 2 MB limit",
      file_path = file,
      class = "tuber_file_too_large"
    )
  }

  yt_check_token()
  track_quota_usage("thumbnails", "set")

  req <- tuber_request(
    "thumbnails/set",
    query = list(videoId = video_id, uploadType = "media"),
    prefix = "upload/youtube/v3"
  ) |>
    req_method("POST") |>
    req_body_file(file, type = guess_type(file, empty = "application/octet-stream"))

  resp <- tuber_perform(req)
  list(request = resp, content = tuber_json(resp))
}
