#' @title \pkg{tuber} provides access to the YouTube API V3.
#'
#' @description \pkg{tuber} provides access to the YouTube API V3 via
#' RESTful calls.
#'
#' @name tuber
#' @importFrom httr GET POST DELETE authenticate config stop_for_status
#' @importFrom httr upload_file content oauth_endpoints oauth_app oauth2.0_token
#' @importFrom utils read.table
#' @importFrom plyr ldply
#' @importFrom dplyr bind_rows
#' @importFrom purrr map_df
#' @docType package
NULL

#' Check if authentication token is in options
#' @return A Token2.0 class
#' @export
yt_token <- function() {
  getOption("google_token")
}

#' @export
#' @rdname yt_token
yt_authorized <- function() {
  !is.null(yt_token())
}

#' @rdname yt_token
yt_check_token <- function() {

  if (!yt_authorized()) {
    stop("Please get a token using yt_oauth().\n")
  }

}

#'
#' GET
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}}.
#' @return list

tuber_GET <- function(path, query, ...) {

  yt_check_token()

  req <- GET("https://www.googleapis.com", path = paste0("youtube/v3/", path),
             query = query, config(token = getOption("google_token")), ...)

  tuber_check(req)
  res <- content(req)

  res
}

#'
#' POST
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param body passing image through body
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}}.
#'
#' @return list

tuber_POST <- function(path, query, body = "", ...) {

  yt_check_token()

  req <- POST("https://www.googleapis.com", path = paste0("youtube/v3/", path),
              body = body, query = query,
              config(token = getOption("google_token")), ...)

  tuber_check(req)
  res <- content(req)

  res
}

#'
#' DELETE
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}}.
#' @return list

tuber_DELETE <- function(path, query, ...) {

  yt_check_token()

  req <- DELETE("https://www.googleapis.com", path = paste0("youtube/v3/", path),
                query = query, config(token = getOption("google_token")), ...)

  tuber_check(req)
  res <- content(req)

  res
}

#'
#' Request Response Verification
#'
#' @param  req request
#' @return in case of failure, a message

tuber_check <- function(req) {

  if (req$status_code < 400) return(invisible(NULL))
  orig_out <-  httr::content(req, as = "text")
  out <- try({
    jsonlite::fromJSON(
      orig_out,
      flatten = TRUE)
  }, silent = TRUE)
  if (inherits(out, "try-error")) {
    msg <- orig_out
  } else {
    msg <- out$error$message
  }
  msg <- paste0(msg, "\n")
  stop("HTTP failure: ", req$status_code, "\n", msg, call. = FALSE)
}
