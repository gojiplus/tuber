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
#' @param part The part parameter serves two purposes in this operation.
#' It identifies the properties that the write operation will set as
#' well as the properties that the API response will include.
#' See \url{https://developers.google.com/youtube/v3/docs/videos/insert#usage}
#' @param ... Additional arguments to send to \code{\link{tuber_POST}} and
#' therefore \code{\link{POST}}
#' @param open_url Should the video be opened using \code{\link{browseURL}}
#'
#' @note The information for `status` and `snippet` are at
#' \url{https://developers.google.com/youtube/v3/docs/videos#resource}
#' but the subset of these fields to pass in are located at:
#' \url{https://developers.google.com/youtube/v3/docs/videos/insert}
#'
#' @return A list of the response object from the \code{POST}, content,
#' and the URL of the uploaded
#' @export
#'
#' @importFrom jsonlite toJSON
#' @importFrom utils browseURL
#' @importFrom httr upload_file
#' @examples
#' snippet = list(
#' title = "Test Video",
#' description = "This is just a random test.",
#' tags = c("r language", "r programming", "data analysis")
#' )
#' status = list(privacyStatus = "private")

upload_video <- function(
  file,
  snippet = list(),
  status = list(privacyStatus = "public"),
  query = NULL,
  part = "snippet,status",
  open_url = FALSE,
  ...
) {


  query <- as.list(query)
  query$part <- part

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
      tags = list(tags)
    }
    snippet$tags = tags
  }



  metadata <- tempfile()
  body <- list()
  body$snippet = snippet
  body$status = status

  body <- jsonlite::toJSON(body, auto_unbox = TRUE)
  writeLines(body, metadata)

  # body <- list(
  #   snippet = jsonlite::toJSON(snippet, auto_unbox = auto_unbox),
  #   status = jsonlite::toJSON(status, auto_unbox = auto_unbox),
  #   y = httr::upload_file(file))

  body <- list(
    metadata = upload_file(metadata, type = "application/json; charset=UTF-8"),
    y = httr::upload_file(file))



  yt_check_token()
  # need diff from regular tuber_POST because of upload/
  req <- httr::POST("https://www.googleapis.com/upload/youtube/v3/videos",
                    body = body, query = query,
                    config(token = getOption("google_token")),
                    ...)
  if (httr::status_code(req) > 300)  {
    print(body)
    print(query)
    stop("Request was bad")
  }
  tuber_check(req)
  res <- content(req)
  url = paste0("https://www.youtube.com/watch?v=", res$id)
  if (open_url) {
    browseURL(url)
  }
  list(request = req, content = res,
       url = url)
}