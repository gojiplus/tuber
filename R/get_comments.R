#' Get Comments On a Video
#'
#' @param video_id id of the video; required
#' @param simplify Boolean. Default is TRUE. If TRUE, the function returns a data frame. Else a list with all the information returned.
#' @param maxResults Default is 20. A numeric. Takes values between 20 and 100.
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

get_comments <- function (video_id=NULL, simplify=TRUE, maxResults=20) {

	if (is.null(video_id)) stop("Must specify a video ID")
	if(maxResults < 20 | maxResults > 100) stop("maxResults only takes a value between 20 and 100")

	yt_check_token()
	
	querylist <- list(part="snippet", videoId = video_id, maxResults=maxResults)
	req <- GET("https://www.googleapis.com/youtube/v3/commentThreads", query=querylist, config(token = getOption("google_token")))
	stop_for_status(req)
	res <- content(req)
	
	if (simplify==TRUE) {
		simple_res  <- lapply(res$items, function(x) x$snippet$topLevelComment$snippet)
		simpler_res <- as.data.frame(do.call(rbind, simple_res))

		return(invisible(simpler_res))
	}

	return(invisible(res))	

}

