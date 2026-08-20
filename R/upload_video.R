#' Upload Video to Youtube
#'
#' @param file Filename of the video locally
#' @param snippet Additional fields for the video, including `description`
#' and `title`.  See
#' \url{https://developers.google.com/youtube/v3/docs/videos#resource} for
#' other fields.  Coerced to a JSON object
#' @param status Additional fields to be put into the \code{status} input.
#' options for `status` are `license` (which should hold:
#' `creativeCommon`, or `youtube`), `privacyStatus`, `publicStatsViewable`,
#' `publishAt`.
#' @param notify_subscribers Whether YouTube should notify subscribers about
#'   the new video.
#' @param on_behalf_of_content_owner Optional YouTube content-owner ID. This is
#'   only available to authorized YouTube content partners.
#' @param content_owner_channel_id Optional channel ID for a content
#'   partner upload. This must be supplied with `on_behalf_of_content_owner`.
#' @param ... Additional arguments to send to \code{\link{tuber_POST}} and
#' therefore \code{\link[httr]{POST}}
#' @param open_url Should the video be opened using \code{\link{browseURL}}
#'
#' @note The information for `status` and `snippet` are at
#' \url{https://developers.google.com/youtube/v3/docs/videos#resource}
#' but the subset of these fields to pass in are located at:
#' \url{https://developers.google.com/youtube/v3/docs/videos/insert}
#' The `part`` parameter serves two purposes in this operation.
#' It identifies the properties that the write operation will set, this will be
#' automatically detected by the names of `body`.
#' See \url{https://developers.google.com/youtube/v3/docs/videos/insert#usage}
#' @return A list of the response object from the \code{\link[httr]{POST}}, content,
#' and the URL of the uploaded
#' @export
#'
#' @importFrom utils browseURL
#' @importFrom httr upload_file
#' @importFrom mime guess_type
#' @examples
#' \dontrun{
#' snippet = list(
#' title = "Test Video",
#' description = "This is just a random test.",
#' tags = c("r language", "r programming", "data analysis")
#' )
#' status = list(privacyStatus = "private")
#' }

upload_video <- function(
  file,
  snippet = NULL,
  status = list(privacyStatus = "public"),
  notify_subscribers = TRUE,
  on_behalf_of_content_owner = NULL,
  content_owner_channel_id = NULL,
  open_url = FALSE,
  ...
) {
  # Modern validation using checkmate
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")
  assert_logical(notify_subscribers, len = 1, .var.name = "notify_subscribers")
  assert_logical(open_url, len = 1, .var.name = "open_url")

  if (!file.exists(file)) {
    abort("File does not exist",
          file_path = file,
          class = "tuber_file_not_found")
  }

  # Validate optional parameters
  if (!is.null(snippet)) {
    assert_list(snippet, .var.name = "snippet")
  }
  if (!is.null(status)) {
    assert_list(status, .var.name = "status")
  }
  if (!is.null(on_behalf_of_content_owner)) {
    assert_character(
      on_behalf_of_content_owner,
      len = 1,
      min.chars = 1,
      .var.name = "on_behalf_of_content_owner"
    )
  }
  if (!is.null(content_owner_channel_id)) {
    assert_character(
      content_owner_channel_id,
      len = 1,
      min.chars = 1,
      .var.name = "content_owner_channel_id"
    )
  }
  if (xor(
    is.null(on_behalf_of_content_owner),
    is.null(content_owner_channel_id)
  )) {
    abort(
      "Content-owner uploads require both content-owner arguments.",
      class = "tuber_conflicting_parameters"
    )
  }
  if ("privacyStatus" %in% names(status)) {
    status$privacyStatus <- match.arg(
      status$privacyStatus,
      choices = c("private", "public", "unlisted")
    )
  }

  if ("license" %in% names(status)) {
    status$license <- match.arg(
      status$license,
      choices = c("creativeCommon", "youtube")
    )
  }

  if ("tags" %in% names(snippet)) {
    tags <- snippet$tags
    if (length(tags) == 1) {
      tags <- list(tags)
    }
    snippet$tags <- tags
  }

  if (length(snippet) == 0) {
    snippet <- NULL
  }

  if (length(status) == 0) {
    status <- NULL
  }

  metadata <- Filter(Negate(is.null), list(snippet = snippet, status = status))
  if (length(metadata) == 0) {
    abort(
      "At least one of `snippet` or `status` must contain video metadata.",
      class = "tuber_missing_video_metadata"
    )
  }

  part <- paste(names(metadata), collapse = ",")
  query <- list(
    uploadType = "resumable",
    part = part,
    notifySubscribers = tolower(as.character(notify_subscribers))
  )
  if (!is.null(on_behalf_of_content_owner)) {
    query$onBehalfOfContentOwner <- on_behalf_of_content_owner
    query$onBehalfOfContentOwnerChannel <- content_owner_channel_id
  }
  metadata_json <- toJSON(metadata, auto_unbox = TRUE, null = "null")
  video_type <- mime::guess_type(file, empty = "application/octet-stream")

  yt_check_token()
  track_quota_usage("videos", "insert")

  resumable_upload_req <- POST(
    "https://www.googleapis.com/upload/youtube/v3/videos",
    query = query,
    body = metadata_json,
    encode = "raw",
    config(token = getOption("google_token")),
    httr::add_headers(
      "Content-Type" = "application/json; charset=UTF-8",
      "X-Upload-Content-Length" = file.size(file),
      "X-Upload-Content-Type" = video_type
    ),
    ...
  )

  if (status_code(resumable_upload_req) < 200 ||
      status_code(resumable_upload_req) >= 300) {
    abort("Failed to initiate resumable upload",
          status_code = status_code(resumable_upload_req),
          class = "tuber_upload_init_failed")
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
    body = upload_file(file, type = video_type),
    config(token = getOption("google_token")),
    ...
  )

  if (status_code(upload_req) < 200 || status_code(upload_req) >= 300) {
    abort("Failed to upload video",
          status_code = status_code(upload_req),
          class = "tuber_video_upload_failed")
  }

  tuber_check(upload_req)

  res <- content(upload_req)
  url <- paste0("https://www.youtube.com/watch?v=", res$id)

  if (open_url) {
    browseURL(url)
  }

  list(request = upload_req, content = res,
       url = url)
}
