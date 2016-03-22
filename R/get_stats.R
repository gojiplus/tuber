#' Get statistics of a Video
#'
#' @param video_id Character. Id of the video. Required.
#' 
#' @return list with 5 elements: viewCount, likeCount, dislikeCount, favoriteCount, commentCount
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#' \dontrun{
#' get_stats(video_id="N708P-A45D0")
#' }

get_stats <- function (video_id=NULL) {

	if (is.null(video_id)) stop("Must specify a video ID")

	yt_check_token()
	
	querylist <- list(part="statistics", id = video_id)
    
    res <- tuber_GET("videos", querylist)
    #res <- res$items[[1]]$statistics
    res <- res$items[[1]]
	cat('No. of Views', res$viewCount, "\n")
	cat('No. of Likes', res$likeCount, "\n")
	cat('No. of Dislikes', res$dislikeCount, "\n")
	cat('No. of Favorites', res$favoriteCount, "\n")
	cat('No. of Comments', res$commentCount, "\n")
	cat('averageViewDuration', res$averageViewDurationCount, "\n")
	cat('estimatedMinutesWatched', res$estimatedMinutesWatched, "\n")
	 cat('subscribersGained', res$subscribersGainedCount, "\n")
	 cat('subscribersGained', res$subscribersGained, "\n")
	return(invisible(res))
}
