#' Get Comments
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector: 
#' \code{comment_id}: comment ID.
#' \code{parent_id}: parent ID.
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
#' When filter is comment_id, and simplify is TRUE, and there is a correct comment id, it returns a data.frame with 
#' following cols:  id, authorDisplayName, authorProfileImageUrl, authorChannelUrl, value, textDisplay, canRate, viewerRating, likeCount
#' publishedAt, updatedAt
#'  
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/comments/list}
#' 
#' @examples
#' \dontrun{
#' get_comments(filter = c(comment_id="z13dh13j5rr0wbmzq04cifrhtuypwl4hsdk"))
#' }

get_comments <- function (filter = NULL, part = "snippet", text_format = "html", simplify = TRUE, max_results = 100, page_token = NULL, ...) {

	if (max_results < 20 | max_results > 100) stop("max_results only takes a value between 20 and 100")
	if (text_format != "html" & text_format !="plainText") stop("Provide a legitimate value of textFormat.")

	if (!(names(filter) %in% c("parent_id", "comment_id"))) stop("filter can only take one of values: comment_id, parent_id.")
	if ( length(filter) != 1) stop("filter must be a vector of length 1.")

	translate_filter   <- c('parent_id' ='parentId', 'comment_id' = 'id')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	names(filter)      <- yt_filter_name

	querylist <- list(part=part, maxResults=max_results, textFormat=text_format)
	querylist <- c(querylist, filter)

	raw_res <- tuber_GET("comments", querylist, ...)

	if (length(raw_res$items) ==0) { 
    	cat("No comment information available. Likely cause: Incorrect ID. \n")
    	if (simplify == TRUE) return(data.frame())
    	return(list())
    }

	res     <- raw_res$items[[1]]$snippet

	if (simplify==TRUE & part=="snippet") {
		simple_res  <- lapply(raw_res$items, function(x) unlist(x$snippet))
		simpler_res <- as.data.frame(do.call(rbind, simple_res))
		simpler_res$id <- raw_res$items[[1]]$id
		return(simpler_res)
	} 

	raw_res

}

