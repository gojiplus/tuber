#' Get Details of a Video or Videos
#'
#' Get details such as when the video was published, the title, description, thumbnails, category etc.
#' 
#' @param video_id Comma separated list of IDs of the videos for which details are requested. Required. 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return list with the following elements: id (video id that was passed), publishedAt, channelId, title, description, thumbnails, 
#' channelTitle, categoryId, liveBroadcastContent, localized, defaultAudioLanguage
#' 
#' @export

#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list}

#' @examples
#' \dontrun{
#' get_video_details(video_id="yJXTXN4xrI8")
#' }

get_video_details <- function (video_id = NULL, ...){
	
	if (is.null(video_id)) stop("Must specify a video ID")

	querylist <- list(part="snippet", id = video_id)

	raw_res <- tuber_GET("videos",  querylist, ...)
	
	if (length(raw_res$items) ==0) { 
    	cat("No details for this video are available. Likely cause: Incorrect ID. \n")
    	return(list())
    }

    res <- raw_res$items[[1]]

	c(id = res$id, res$snippet)
}

