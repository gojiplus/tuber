#' Get Comments On a Video
#'
#' @param video_id id of the video; required
#' @return Nested named list. The entry \code{items} is a list of comments along with meta information. 
#' Within each of the \code{items} is an item \code{snippet} which has an item \code{topLevelComment$snippet$textDisplay}
#' that contains the actual comment.
#'  
#' @export
#' @references \url{https://console.developers.google.com/project}
#' @examples
#' \dontrun{
#' get_comments(video_id="N708P-A45D0")
#' }

get_comments <- function (video_id=NULL) {

	if (is.null(video_id)) stop("Must specify a video ID")

	yt_check_token()

	querylist <- list(part="snippet", videoId = video_id)
	req <- GET("https://www.googleapis.com/youtube/v3/commentThreads", query=querylist, config(token = getOption("google_token")))
	stop_for_status(req)
	res <- content(req)
	
	return(invisible(res))	
}

