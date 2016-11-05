#' Get statistics of a Video
#'
#' @param video_id Character. Id of the video. Required.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return list with 6 elements: id, viewCount, likeCount, dislikeCount, favoriteCount, commentCount
#'
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list#parameters}
#' 
#' @examples
#' \dontrun{
#' get_stats(video_id="N708P-A45D0")
#' }

get_stats <- function (video_id=NULL, ...) {

	if (is.null(video_id)) stop("Must specify a video ID")
	
	querylist <- list(part="statistics", id = video_id)
    
    raw_res <- tuber_GET("videos", querylist, ...)

    if (length(raw_res$items) ==0) { 
    	cat("No statistics for this video are available. Likely cause: Incorrect ID. \n")
    	return(list())
    }

    res      <- raw_res$items[[1]]
    stat_res <- res$statistics 

	cat('No. of Views', stat_res$viewCount, "\n")
	cat('No. of Likes', stat_res$likeCount, "\n")
	cat('No. of Dislikes', stat_res$dislikeCount, "\n")
	cat('No. of Favorites', stat_res$favoriteCount, "\n")
	cat('No. of Comments', stat_res$commentCount, "\n")
 
	return(invisible(c(id=res$id, stat_res)))
}
