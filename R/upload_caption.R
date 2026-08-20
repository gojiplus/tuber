#' Upload a Caption Track
#'
#' Uploads a timed caption file using YouTube's resumable media-upload
#' protocol. The request requires OAuth 2.0 authorization.
#'
#' @param file Path to a caption file containing timing information.
#' @param video_id YouTube video ID.
#' @param caption_name Name of the caption track. YouTube limits names to 150
#'   characters.
#' @param language BCP 47 language tag for the caption track.
#' @param is_draft Whether the caption track should remain a draft.
#' @param on_behalf_of_content_owner Optional YouTube content-owner ID. This is
#'   only available to authorized YouTube content partners.
#' @param open_url Whether to open the video's YouTube URL after a successful
#'   upload.
#' @param ... Additional arguments passed to [httr::POST()] and [httr::PUT()].
#'
#' @return A list containing the final HTTP response, parsed caption resource,
#'   and video URL.
#' @export
#'
#' @references
#' <https://developers.google.com/youtube/v3/docs/captions/insert>
#'
#' @examples
#' \dontrun{
#' upload_caption(
#'   file = "captions.vtt",
#'   video_id = "dQw4w9WgXcQ",
#'   caption_name = "English"
#' )
#' }
upload_caption <- function(
  file,
  video_id,
  caption_name,
  language = "en-US",
  is_draft = FALSE,
  on_behalf_of_content_owner = NULL,
  open_url = FALSE,
  ...
) {
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")
  assert_character(
    caption_name,
    len = 1,
    min.chars = 1,
    max.chars = 150,
    .var.name = "caption_name"
  )
  assert_character(language, len = 1, min.chars = 1, .var.name = "language")
  assert_logical(is_draft, len = 1, .var.name = "is_draft")
  assert_logical(open_url, len = 1, .var.name = "open_url")
  if (!is.null(on_behalf_of_content_owner)) {
    assert_character(
      on_behalf_of_content_owner,
      len = 1,
      min.chars = 1,
      .var.name = "on_behalf_of_content_owner"
    )
  }

  if (!file.exists(file)) {
    abort(
      "Caption file does not exist",
      file_path = file,
      class = "tuber_file_not_found"
    )
  }
  if (file.size(file) > 100 * 1024^2) {
    abort(
      "Caption file exceeds YouTube's 100 MB limit",
      file_path = file,
      class = "tuber_file_too_large"
    )
  }
  if (!grepl("^[A-Za-z0-9_-]{11}$", video_id)) {
    abort(
      "Invalid YouTube video ID format",
      video_id = video_id,
      class = "tuber_invalid_video_id"
    )
  }

  metadata <- list(snippet = list(
    videoId = video_id,
    language = language,
    name = caption_name,
    isDraft = is_draft
  ))
  query <- list(uploadType = "resumable", part = "snippet")
  if (!is.null(on_behalf_of_content_owner)) {
    query$onBehalfOfContentOwner <- on_behalf_of_content_owner
  }
  caption_type <- mime::guess_type(file, empty = "application/octet-stream")

  yt_check_token()
  track_quota_usage("captions", "insert")

  resumable_upload_req <- POST(
    "https://www.googleapis.com/upload/youtube/v3/captions",
    query = query,
    body = toJSON(metadata, auto_unbox = TRUE, null = "null"),
    encode = "raw",
    config(token = getOption("google_token")),
    httr::add_headers(
      "Content-Type" = "application/json; charset=UTF-8",
      "X-Upload-Content-Length" = file.size(file),
      "X-Upload-Content-Type" = caption_type
    ),
    ...
  )

  if (status_code(resumable_upload_req) < 200 ||
        status_code(resumable_upload_req) >= 300) {
    tuber_check(resumable_upload_req)
    abort(
      "Failed to initiate caption upload",
      status_code = status_code(resumable_upload_req),
      class = "tuber_upload_init_failed"
    )
  }

  upload_url <- headers(resumable_upload_req)[["location"]]
  if (is.null(upload_url) || !nzchar(upload_url)) {
    abort(
      "YouTube did not return a resumable upload URL.",
      class = "tuber_upload_location_missing"
    )
  }

  upload_req <- PUT(
    upload_url,
    body = upload_file(file, type = caption_type),
    config(token = getOption("google_token")),
    ...
  )
  tuber_check(upload_req)
  if (status_code(upload_req) < 200 || status_code(upload_req) >= 300) {
    abort(
      "Failed to upload caption",
      status_code = status_code(upload_req),
      class = "tuber_caption_upload_failed"
    )
  }

  result <- content(upload_req)
  url <- paste0("https://www.youtube.com/watch?v=", video_id)
  if (open_url) browseURL(url)

  list(request = upload_req, content = result, url = url)
}
