#' Upload Video to Youtube
#'
#' @param video_id ID of the YouTube video
#' @param query Fields for `query` in `GET`
#' @param ... Additional arguments to send to \code{\link{tuber_GET}} and
#' therefore \code{\link{GET}}
#' @return A list of the response object from the \code{GET} and content
#' about captions
#'
#' @examples \dontrun{
#' video_id <- "M7FIvfx5J10"
#' list_captions(video_id)
#' }
list_captions <- function(
  video_id,
  query = NULL,
  ...
) {

  part <- "id,snippet"

  query <- as.list(query)
  query$part <- part
  query$videoId <- video_id

  yt_check_token()
  # need diff from regular tuber_POST because of upload/
  req <- httr::GET("https://www.googleapis.com/youtube/v3/captions",
                    query = query,
                    config(token = getOption("google_token")),
                    ...)
  if (httr::status_code(req) > 300)  {
    print(query)
    print(httr::content(req)$error)
    stop("Request was bad")
  }
  tuber_check(req)
  res <- content(req)

  list(request = req, content = res)
}
