#' Set up Authorization
#'
#' The function looks for .httr-oauth in the working directory. If it doesn't find it, it expects an application ID and a secret.
#' If you want to remove the existing .httr-oauth, set remove_old_oauth to TRUE. By default, it is set to FALSE.
#' The function launches a browser to allow you to authorize the application 
#' 
#' @param app_id client id; required; no default
#' @param app_secret client secret; required; no default
#' @param scope "ssl" or "basic"; required; default is ssl. The scopes are largely exchangeable but ssl yields extra authorizations that come in handy. 
#' @param remove_old_oauth required; default is FALSE. It will remove .httr-oauth if such a file exists in the working directory
#' @return sets the google_token option and also saves .httr_auth in the working directory (find out the working directory via getwd())
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/}
#' @references \url{https://developers.google.com/youtube/v3/guides/auth/client-side-web-apps} for different scopes
#' @examples
#'  \dontrun{
#'	  yt_oauth("998136489867-5t3tq1g7hbovoj46dreqd6k5kd35ctjn.apps.googleusercontent.com", 
#'	           "MbOSt6cQhhFkwETXKur-L9rN")
#' }

yt_oauth <- function (app_id=NULL, app_secret=NULL, scope="ssl", remove_old_oauth=FALSE) {

	if (remove_old_oauth & file.exists('.httr-oauth')) {
		file.remove('.httr-oauth')
	}

	if (file.exists('.httr-oauth')) {
		
		google_token <- readRDS('.httr-oauth')
		google_token <- google_token[[1]]

	} else if(is.null(app_id) | is.null(app_secret)) {
		
		stop("Please provide values for app_id and app_secret")
	
	} else {
	
		oauth_endpoints("google")
		myapp <- oauth_app("google", key = app_id, secret = app_secret)

		if (scope=="ssl") {
	
			google_token <- oauth2.0_token(oauth_endpoints("google"), myapp, scope = "https://www.googleapis.com/auth/youtube.force-ssl")
			
		} else if (scope=="basic") {
	
			google_token <- oauth2.0_token( oauth_endpoints("google"), myapp, scope = "https://www.googleapis.com/auth/youtube")

		}
	}
	
	options(google_token = google_token)

}
