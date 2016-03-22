#' Get statistics of a Video
#'
#' @param video_id Character. Id of the video. Required.
#' 
#' @return list with 5 elements: viewCount, likeCount, dislikeCount, favoriteCount, commentCount
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#' \dontrun{
#' get_channel(channel_id="UChTJTbr5kf3hYazJZO-euHg")
#' }

get_channel <- function (channel_id=NULL) {

	if (is.null(channel_id)) stop("Must specify a channel ID")

	yt_check_token()
	
	querylist <- list(part="contentDetails,statistics,snippet", id = channel_id)
    
    res <- tuber_GET("channels", querylist)
    res1 <- res$items[[1]]$statistics
    res2 <- res$items[[1]]$snippet
    	cat('Channel Title',res2$title)
	cat('No. of Views', res1$viewCount, "\n")
	cat('No. of Subscribers', res1$subscriberCount, "\n")
	cat('No. of Videos', res1$videoCount, "\n")
 
	return(invisible(res))
}
