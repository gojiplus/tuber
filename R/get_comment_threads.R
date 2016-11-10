#' Get Comments Threads
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector: 
#' \code{video_id}: video ID.
#' \code{channel_id}: channel ID.
#' \code{thread_id}: comma-separated list of comment thread IDs
#' \code{threads_related_to_channel}: channel ID.
#'  
#' @param part  Comment resource requested. Required. Comma separated list of one or more of the 
#' following: \code{id, snippet}. e.g., "id, snippet", "id" Default: \code{snippet}.  
#' @param simplify Data Type: Boolean. Default is TRUE. If TRUE, the function returns a data frame. Else a list with all the information returned.
#' @param max_results  Maximum number of items that should be returned. Integer. Optional. Can be between 20 and 100. Default is 100.
#' @param page_token  Specific page in the result set that should be returned. Optional.
#' @param text_format Data Type: Character. Default is "html". Only takes "html" or "plainText." Optional. 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'  
#' @return 
#' Nested named list. The entry \code{items} is a list of comments along with meta information. 
#' Within each of the \code{items} is an item \code{snippet} which has an item \code{topLevelComment$snippet$textDisplay}
#' that contains the actual comment.
#'  
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/commentThreads/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' get_comment_threads(filter = c(video_id="N708P-A45D0"))
#' }

get_comment_threads <- function (filter=NULL, part="snippet", text_format="html", simplify=TRUE, max_results=100, page_token = NULL, ...) {

	if (max_results < 20 | max_results > 100) stop("max_results only takes a value between 20 and 100")
	if (text_format != "html" & text_format !="plainText") stop("Provide a legitimate value of textFormat.")

	if (!(names(filter) %in% c("video_id", "channel_id", "thread_id", "threads_related_to_channel"))) stop("filter can only take one of values: channel_id, video_id, parent_id, threads_related_to_channel.")
	if ( length(filter) != 1) stop("filter must be a vector of length 1.")

	translate_filter   <- c(video_id = 'videoId', thread_id ='id', threads_related_to_channel = 'allThreadsRelatedToChannelId', channel_id = 'channelId')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	names(filter)      <- yt_filter_name

	querylist <- list(part=part, maxResults=max_results, textFormat=text_format)
	querylist <- c(querylist, filter)

	res <- tuber_GET("commentThreads", querylist, ...)
	
	if (simplify==TRUE & part=="snippet") {
		simple_res  <- lapply(res$items, function(x) unlist(x$snippet$topLevelComment$snippet))
		simpler_res <- as.data.frame(do.call(rbind, simple_res))

		return(simpler_res)
	}

	res

}

