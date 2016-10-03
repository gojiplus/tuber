#' Get statistics of a Video
#'
#' @param video_id Character. Id of the video. Required.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return list with 5 elements: viewCount, likeCount, dislikeCount, favoriteCount, commentCount
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list#parameters}
#' @examples
#' \dontrun{
#' get_stats(video_id="N708P-A45D0")
#' }

get_stats <- function (video_id=NULL, ...) {

	if (is.null(video_id)) stop("Must specify a video ID")
	
	querylist <- list(part="statistics", id = video_id)
    
    res <- tuber_GET("videos", querylist, ...)
    res <- res$items[[1]]$statistics

	cat('No. of Views', res$viewCount, "\n")
	cat('No. of Likes', res$likeCount, "\n")
	cat('No. of Dislikes', res$dislikeCount, "\n")
	cat('No. of Favorites', res$favoriteCount, "\n")
	cat('No. of Comments', res$commentCount, "\n")
 
	return(invisible(res))
}
