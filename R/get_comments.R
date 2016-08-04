#' Get Comments On a Video
#'
#' @param part  Comment resource requested. Required. Comma separated list of one or more of the 
#' following: \code{id, snippet}. e.g., "id, snippet", "id" Default: \code{snippet}.  
#' @param video_id ID of the video. Required. Data Type: Character. 
#' @param simplify Data Type: Boolean. Default is TRUE. If TRUE, the function returns a data frame. Else a list with all the information returned.
#' @param max_results Maximum number of items that should be returned. Integer. Optional. Can be between 20 and 100. Default is 100.
#' @param page_token Specific page in the result set that should be returned. Optional.
#' @param text_format Data Type: Character. Default is "html". Only takes "html" or "plainText." Optional. 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'  
#' @return 
#' Nested named list. The entry \code{items} is a list of comments along with meta information. 
#' Within each of the \code{items} is an item \code{snippet} which has an item \code{topLevelComment$snippet$textDisplay}
#' that contains the actual comment.
#'  
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/comments/list}
#' @examples
#' \dontrun{
#' get_comments(video_id="N708P-A45D0")
#' }

get_comments <- function (part="snippet", video_id=NULL, text_format="html", simplify=TRUE, max_results=100, page_token = NULL, ...) {

	if (is.null(video_id)) stop("Must specify a video ID")
	if (max_results < 20 | max_results > 100) stop("max_results only takes a value between 20 and 100")
	if (text_format != "html" & text_format !="plainText") stop("Provide a legitimate value of textFormat.")

	querylist <- list(part=part, videoId = video_id, maxResults=max_results, textFormat=text_format)

	res <- tuber_GET("commentThreads", querylist, ...)
	
	if (simplify==TRUE & part=="snippet") {
		simple_res  <- lapply(res$items, function(x) x$snippet$topLevelComment$snippet)
		simpler_res <- as.data.frame(do.call(rbind, simple_res))

		return(simpler_res)
	}

	res

}

