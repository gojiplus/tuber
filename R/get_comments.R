#' Get Comments On a Video
#'
#' @param video_id Data Type: Character. ID of the video. Required.
#' @param simplify Data Type: Boolean. Default is TRUE. If TRUE, the function returns a data frame. Else a list with all the information returned.
#' @param maxResults Data Type: Numeric. Default is 20. Takes values between 20 and 100. Optional.
#' @param textFormat Data Type: Character. Default is "html". Only takes "html" or "plainText." Optional. 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'  
#' @return Nested named list. The entry \code{items} is a list of comments along with meta information. 
#' Within each of the \code{items} is an item \code{snippet} which has an item \code{topLevelComment$snippet$textDisplay}
#' that contains the actual comment.
#'  
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/}
#' @examples
#' \dontrun{
#' get_comments(video_id="N708P-A45D0")
#' }

get_comments <- function (video_id=NULL, simplify=TRUE, maxResults=20, textFormat="html", ...) {

	if (is.null(video_id)) stop("Must specify a video ID")
	if (maxResults < 20 | maxResults > 100) stop("maxResults only takes a value between 20 and 100")
	if (textFormat != "html" & textFormat !="plainText") stop("Provide a legitimate value of textFormat.")

	querylist <- list(part="snippet", videoId = video_id, maxResults=maxResults, textFormat=textFormat)

	res <- tuber_GET("commentThreads", querylist, ...)
	
	if (simplify==TRUE) {
		simple_res  <- lapply(res$items, function(x) x$snippet$topLevelComment$snippet)
		simpler_res <- as.data.frame(do.call(rbind, simple_res))

		return(invisible(simpler_res))
	}

	return(invisible(res))	

}

