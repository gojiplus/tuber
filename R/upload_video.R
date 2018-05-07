#' Upload Video to Youtube
#'
#' @param file Filename of the video locally
#' @param snippet Additional fields for the video, including `description`
#' and `title`.  See
#' \url{https://developers.google.com/youtube/v3/docs/videos#resource} for
#' other fields.  Coerced to a JSON object
#' @param query Fields for `query` in `POST`
#' @param part The part parameter serves two purposes in this operation.
#' It identifies the properties that the write operation will set as
#' well as the properties that the API response will include.
#' See \url{https://developers.google.com/youtube/v3/docs/videos/insert#usage}
#' @param ... Additional arguments to send to \code{\link{tuber_POST}} and
#' therefore \code{\link{POST}}
#'
#' @return A list of the response object from the \code{POST} and content
#' @export
#'
#' @importFrom jsonlite toJSON
#' @importFrom httr upload_file

upload_video <- function(
  file,
  snippet = list(),
  query = NULL,
  part = "snippet,status",
  ...
) {
  query <- as.list(query)
  query$part <- part
  body <- list(snippet = jsonlite::toJSON(snippet),
              y = httr::upload_file(file))

  yt_check_token()
  # need diff from regular tuber_POST because of upload/
  req <- httr::POST("https://www.googleapis.com/upload/youtube/v3/videos",
                    body = body, query = query,
                    config(token = getOption("google_token")),
                    ...)

  tuber_check(req)
  res <- content(req)
  
  list(request = req, content = res)
}
