#' Get Captions of a Video
#'
#' @param video_id id of the video; required; no default
#' @param lang  language of the caption; required; default is english ("en")
#' @return list with 5 elements - viewCount, likeCount, dislikeCount, favoriteCount, commentCount
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#' get_captions(video_id="yJXTXN4xrI8")

get_captions <- function (video_id=NULL, lang="en") {

	google_token <- getOption("google_token")
	if (is.null(google_token)) stop("Please set up authorization via yt_oauth()).")

	# Try getting captions directly
	req <- httr::GET(paste0("http://video.google.com/timedtext?lang=", lang, "&v=", video_id))

	if (length(content(req))==0) {
		req <- httr::GET(paste0("https://www.googleapis.com/youtube/v3/captions?part=snippet&videoId=", video_id), config(token = google_token))
		httr::stop_for_status(req)
		# Multiple caption tracks possible but for now harvest just the first
		caption_id <- content(req)$items[[1]]$id
		caption <- httr::GET(paste0("https://www.googleapis.com/youtube/v3/captions/", caption_id), config(token = google_token))
		if(caption$status!=200) stop("Caption Track Either Not Found or Not Accessible.")
		req <- NA
	}

	content(req)
}
