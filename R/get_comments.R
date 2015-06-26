#' Get Statistics of a Video
#'
#' @param video_id id of the video; required
#' @return list with 5 elements - viewCount, likeCount, dislikeCount, favoriteCount, commentCount
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#' get_comments(video_id="N708P-A45D0")

get_comments <- function (video_id=NULL){

	google_token=getOption("google_token")
	if (is.null(google_token)) stop("Please set up authorization via yt_oauth()).")

	req <- httr::GET(paste0("https://www.googleapis.com/youtube/v3/videos?part=snippet&id=", video_id), config(token = google_token))
	httr::stop_for_status(req)
	req
}

