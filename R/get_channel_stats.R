#' Get statistics of a Channel
#'
#' @param channel_id Character. Id of the channel
#' 
#' @return list with 5 elements: viewCount, likeCount, dislikeCount, favoriteCount, commentCount
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' @examples
#' \dontrun{
#' get_channel_stats(channel_id="UChTJTbr5kf3hYazJZO-euHg")
#' }

get_channel_stats <- function (channel_id = NULL, ...) {

	if (is.null(channel_id)) stop("Must specify a channel ID")

	yt_check_token()
	
	querylist <- list(part="statistics,snippet", id = channel_id)
    
    res <- tuber_GET("channels", querylist, ...)
    res1 <- res$items[[1]]$statistics
    res2 <- res$items[[1]]$snippet
    
    cat('Channel Title',res2$title, "\n")
	cat('No. of Views', res1$viewCount, "\n")
	cat('No. of Subscribers', res1$subscriberCount, "\n")
	cat('No. of Videos', res1$videoCount, "\n")
 
	res
}
