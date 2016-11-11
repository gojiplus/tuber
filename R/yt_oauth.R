#' Set up Authorization
#'
#' The function looks for \code{.httr-oauth} in the working directory. If it doesn't find it, it expects an application ID and a secret.
#' If you want to remove the existing \code{.httr-oauth}, set remove_old_oauth to TRUE. By default, it is set to FALSE.
#' The function launches a browser to allow you to authorize the application 
#' 
#' @param app_id client id; required; no default
#' @param app_secret client secret; required; no default
#' @param scope Character. \code{ssl}, \code{basic}, \code{own_account_readonly}, \code{upload_and_manage_own_videos} and \code{partner_audit}. 
#' Required. \code{ssl} and \code{basic} are basically interchangeable. Default is \code{ssl}.
#' @param token path to file containing the token. If a path is given, the function will first try to read from it. 
#' Default is \code{.httr-oauth} in the local directory.
#' So if there is such a file, the function will first try to read from it.
#' @param \dots Additional arguments passed to \code{\link{oauth2.0_token}}
#' 
#' @return sets the google_token option and also saves \code{.httr_oauth} in the working directory (find out the working directory via \code{getwd()})
#' 
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/}
#' @references \url{https://developers.google.com/youtube/v3/guides/auth/client-side-web-apps} for different scopes
#' 
#' @examples
#'  \dontrun{
#'	  yt_oauth("998136489867-5t3tq1g7hbovoj46dreqd6k5kd35ctjn.apps.googleusercontent.com", 
#'	           "MbOSt6cQhhFkwETXKur-L9rN")
#' }

yt_oauth <- function (app_id=NULL, app_secret=NULL, scope="ssl", token = '.httr-oauth', ...) {

	if (file.exists(token)) {
		
		google_token <- readRDS(token)
		google_token <- google_token[[1]]
				
	} else if(is.null(app_id) | is.null(app_secret)) {
		
		stop("Please provide values for app_id and app_secret")
	
	} else {
	
		myapp <- oauth_app("google", key = app_id, secret = app_secret)

		if (scope == "ssl") {
	
			google_token <- oauth2.0_token(oauth_endpoints("google"), myapp, scope = "https://www.googleapis.com/auth/youtube.force-ssl", ...)
			
		} else if (scope == "basic") {
	
			google_token <- oauth2.0_token( oauth_endpoints("google"), myapp, scope = "https://www.googleapis.com/auth/youtube", ...)

		} else if (scope == "own_account_readonly") {
			
			google_token <- oauth2.0_token( oauth_endpoints("google"), myapp, scope = "https://www.googleapis.com/auth/youtube.readonly", ...)
		
		} else if (scope == "upload_and_manage_own_videos") {
			
			google_token <- oauth2.0_token( oauth_endpoints("google"), myapp, scope = "https://www.googleapis.com/auth/youtube.upload", ...)
		
		} else if (scope == "partner_audit") {
			
			google_token <- oauth2.0_token( oauth_endpoints("google"), myapp, scope = "https://www.googleapis.com/auth/youtubepartner-channel-audit", ...)
		}
	}
	
	options(google_token = google_token)

}
