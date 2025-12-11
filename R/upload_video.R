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
#' @param query Fields for `query` in `POST`
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
#' @importFrom jsonlite toJSON
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
  query = NULL,
  open_url = FALSE,
  ...
) {
  # Modern validation using checkmate
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")
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
  if (!is.null(query)) {
    assert_list(query, .var.name = "query")
  }
  if ("privacyStatus" %in% names(status)) {
    p <- status$privacyStatus
    p <- match.arg(p, choices = c("private", "public", "unlisted"))
  }

  if ("license" %in% names(status)) {
    p <- status$license
    p <- match.arg(p, choices = c("creativeCommon", "youtube"))
  }

  if ("tags" %in% names(snippet)) {
    tags <- snippet$tags
    if (length(tags) == 1) {
      tags <- list(tags)
    }
    snippet$tags <- tags
  }

  metadata <- tempfile()
  body <- list()

  if (length(snippet) == 0) {
    snippet <- NULL
  }

  if (length(status) == 0) {
    status <- NULL
  }

  body$snippet <- snippet
  body$status <- status

  part <- paste(names(body), collapse = ",")

  query <- as.list(query)
  query$part <- part

  body <- jsonlite::toJSON(body, auto_unbox = TRUE)
  writeLines(body, metadata)

  body <- list(
    metadata = httr::upload_file(metadata, type = "application/json; charset=UTF-8"),
    y = httr::upload_file(file)
  )

  yt_check_token()

  headers <- c(
    "Authorization" = paste("Bearer", getOption("google_token")), #$credentials$access_token),
    "Content-Length" = file.size(file),
    "Content-Type" = "application/json; charset=utf-8",
    "X-Upload-Content-Length" = file.size(file),
    "X-Upload-Content-Type" = mime::guess_type(file)
  )

  resumable_upload_url <- "https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=parts"
  resumable_upload_req <- httr::POST(resumable_upload_url,
                                     config(token = getOption("google_token")),
                                     httr::add_headers(headers),
                                     ...
  )

  if (httr::status_code(resumable_upload_req) != 200) {
    abort("Failed to initiate resumable upload",
          status_code = httr::status_code(resumable_upload_req),
          class = "tuber_upload_init_failed")
  }

  upload_url <- httr::headers(resumable_upload_req)$`x-guploader-uploadid`

  upload_req <- httr::PUT(upload_url,
                          body = httr::upload_file(file),
                          config(token = getOption("google_token")),
                          ...
  )

  if (httr::status_code(upload_req) != 200) {
    abort("Failed to upload video",
          status_code = httr::status_code(upload_req),
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
