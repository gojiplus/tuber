#' \pkg{tuber} provides access to the YouTube API V3.
#'
#' @name tuber
#' @importFrom httr GET POST authenticate config stop_for_status upload_file content oauth_endpoints oauth_app oauth2.0_token
#' @importFrom utils read.table
#' @importFrom plyr ldply
#' @docType package
NULL

#' Check if authentication token is in options
#'

yt_check_token <- function() {

  app_token <- getOption("google_token")
    if (is.null(app_token)) stop("Please get a token using yt_oauth().\n")

}

#' 
#' Base POST AND GET functions. Not exported.

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

  if (req$status_code < 400) return(invisible())

  stop("HTTP failure: ", req$status_code, "\n", call. = FALSE)
}
