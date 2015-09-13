#' Get Comments To a Video
#'
#' @param video_id id of the video; required
#' @return XML list of comments
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#'  \dontrun{get_comments(video_id="N708P-A45D0")}

get_comments <- function (video_id=NULL){

	google_token=getOption("google_token")
	if (is.null(google_token)) stop("Please set up authorization via yt_oauth()).")

	# Try getting comments directly
	req <- GET(paste0("https://gdata.youtube.com/feeds/api/videos/", video_id, "/comments?orderby=published"))
	res <- content(req, as="text")

	# Error handling
	if (req$status==400) stop(res)
	httr::stop_for_status(req)
	
	if (length(content(req))==0) {
		req <- GET(paste0("https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=", video_id), config(token = google_token))
		stop_for_status(req)
		res <- content(req)
	}
	res	
}

