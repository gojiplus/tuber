#' Get Captions of a Video
#' 
#' A few of Youtube videos have caption tracks available from an older 
#' YouTube API. If that caption track is available, this function returns that,
#' Or it returns caption track specified by id resource. Check \code{\link{list_caption_tracks}} for more
#' information.
#' 
#' @param video_id ID of the video whose captions are requested. Required. No default.
#' @param lang  Language of the caption; required; default is \code{"en"} (English)
#' @param id    String. id of the caption track that is being retrieved
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return String. 
#' 
#' @export
#'  
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' get_captions(video_id="yJXTXN4xrI8")
#' get_captions(id="y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
#' }

get_captions <- function (video_id=NULL, lang = "en", id = NULL, ...) {

	if (!is.character(video_id) & !is.character(id)) stop("Must specify a valid video_id or id.")

	# Try getting captions directly
	req <- GET(paste0("http://video.google.com/timedtext?lang=", lang, "&v=", video_id))
	req <- content(req)

	# If not try other things
	if (length(req)==0) {
		
		querylist = list(id = id)
		raw_res <- tuber_GET("captions", query = querylist, ...)
		
		if (length(raw_res$items) ==0) { 
    		cat("No caption tracks available. Likely cause: Incorrect video ID. \n")
    		return(list())
    	}

		return(raw_res)
	}

	req
}

