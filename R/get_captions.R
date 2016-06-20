#' Get Captions of a Video
#' 
#' 
#' @param video_id id of the video; required; no default
#' @param lang  language of the caption; required; default is english ("en")
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://console.cloud.google.com/}
#' @examples
#' \dontrun{
#' get_captions(video_id="yJXTXN4xrI8")
#' }

get_captions <- function (video_id=NULL, lang="en", ...) {

	if (is.null(video_id)) stop("Must specify a video ID")

	yt_check_token()

	# Try getting captions directly
	req <- GET(paste0("http://video.google.com/timedtext?lang=", lang, "&v=", video_id))

	# If not try other things
	if (length(content(req))==0) {
		querylist = list(part="snippet", videoId = video_id)
		req <- GET("https://www.googleapis.com/youtube/v3/captions", query = querylist, config(token = getOption("google_token")), ...)
		stop_for_status(req)
		# Multiple caption tracks possible but for now harvest just the first
		caption_id <- content(req)$items[[1]]$id

		caption <- GET(paste0("https://www.googleapis.com/youtube/v3/captions/", caption_id), config(token = getOption("google_token")), ...)
		if(caption$status!=200) stop("Caption Track Either Not Found or Not Accessible.")
		req <- NA
	}

	content(req)
}
