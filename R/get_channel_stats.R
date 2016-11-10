#' Get statistics of a Channel
#'
#' @param channel_id Character. Id of the channel
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return nested named list with top element names:
#' kind, etag, id, snippet (list of details of the channel including title), statistics (list of 5)
#' 
#' If the channel_id is mistyped or there is no information, an empty list is returned
#' 
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' get_channel_stats(channel_id="UChTJTbr5kf3hYazJZO-euHg")
#' }

get_channel_stats <- function (channel_id = NULL, ...) {

	if (is.null(channel_id)) stop("Must specify a channel ID")
	
	querylist <- list(part = "statistics,snippet", id = channel_id)
    
    raw_res  <- tuber_GET("channels", querylist, ...)

    if (length(raw_res$items) ==0) { 
    	cat("No channel stats available. Likely cause: Incorrect channel_id. \n")
    	return(list())
    }

    res  <- raw_res$items[[1]] 
    res1 <- res$statistics
    res2 <- res$snippet
    
    cat('Channel Title:', res2$title, "\n")
	cat('No. of Views:', res1$viewCount, "\n")
	cat('No. of Subscribers:', res1$subscriberCount, "\n")
	cat('No. of Videos:', res1$videoCount, "\n")
 	
	res
}
