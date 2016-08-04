#' Get Details of a Video or Videos
#'
#' Get details such as when the video was published, the title, description, thumbnails, category etc.
#' 
#' @param video_id Comma separated list of IDs of the videos for which details are requested. Required. 
#' @return list with the following elements - publishedAt, channelId, title, description, thumbnails, 
#' channelTitle, categoryId, liveBroadcastContent, localized, defaultAudioLanguage
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @export
#' @references \url{https://developers.google.com/youtube/v3/}
#' @examples
#' \dontrun{
#' get_video_details(video_id="yJXTXN4xrI8")
#' }

get_video_details <- function (video_id = NULL, ...){
	
	if (is.null(video_id)) stop("Must specify a video ID")

	yt_check_token()

	querylist <- list(part="snippet", id = video_id)

	req <- tuber_GET("videos",  querylist, ...)
	
	res <- req$items[[1]]$snippet

	# Return a list
	res
}

