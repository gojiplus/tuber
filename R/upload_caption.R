#' Upload Video Caption to Youtube
#'
#' @param file Filename of the caption, probably `.srt`
#' @param video_id YouTube Video ID.  Try \code{\link{list_my_videos}} for examples.
#' @param caption_name character vector of the name for the caption.
#' @param is_draft logical indicating whether the caption track is a draft.
#' @param query Fields for `query` in `POST`
#' @param ... Additional arguments to send to \code{\link[httr]{POST}}
#' @param open_url Should the video be opened using \code{\link{browseURL}}
#' @param language character string of `BCP47` language type.
#' See \url{https://www.rfc-editor.org/rfc/bcp/bcp47.txt} for language specification
#'
#' @note See
#' \url{https://developers.google.com/youtube/v3/docs/captions#resource} for
#' full specification
#' @return A list of the response object from the \code{\link[httr]{POST}}, content,
#' and the URL of the video
#' @export
#'
#' @examples \dontrun{
#' xx = list_my_videos()
#' video_id = xx$contentDetails.videoId[1]
#' video_id = as.character(video_id)
#' language = "en-US"
#' }
upload_caption <- function(
  file,
  video_id,
  language = "en-US",
  caption_name,
  is_draft = FALSE,
  query = NULL,
  open_url = FALSE,
  ...
) {

  snippet <- list(
    videoId = as.character(video_id)
  )
  snippet$language <- language
  snippet$name <- caption_name
  snippet$isDraft <- is_draft

  metadata <- tempfile()

  body <- list()
  body$snippet <- snippet
  part <- paste(names(body), collapse = ",")

  query <- as.list(query)
  query$part <- part

  body <- jsonlite::toJSON(body, auto_unbox = TRUE)
  writeLines(body, metadata)

  body <- list(
    metadata = upload_file(metadata, type = "application/json; charset=UTF-8"),
    y = httr::upload_file(file, type = "*/*"))



  yt_check_token()
  # need diff from regular tuber_POST because of upload/
  req <- httr::POST("https://www.googleapis.com/upload/youtube/v3/captions",
                    body = body, query = query,
                    config(token = getOption("google_token")),
                    ...)
  if (httr::status_code(req) > 300)  {
    print(body)
    print(paste0("File is: ", metadata))
    cat(readLines(metadata))
    cat("\n")
    print(query)
    print(httr::content(req)$error)
    stop("Request was bad")
  }
  tuber_check(req)
  res <- content(req)
  url <- paste0("https://www.youtube.com/watch?v=", video_id)
  if (open_url) {
    browseURL(url)
  }
  list(request = req, content = res,
       url = url)
}
