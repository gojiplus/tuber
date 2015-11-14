#' \pkg{tuber} provides access to the YouTube API V3.
#'
#' @name tuber
#' @importFrom httr GET POST authenticate config stop_for_status upload_file content oauth_endpoints oauth_app oauth2.0_token
#' @docType package
NULL

#' Check if authentication token is in options
#'

yt_check_token <- function() {

	app_token = getOption('google_token')
    if (is.null(app_token)) stop("Please get a token using yt_oauth()")

}