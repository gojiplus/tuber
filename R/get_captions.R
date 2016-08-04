#' Get Captions of a Video
#' 
#' @param part  Caption resource requested. Required. Comma separated list of one or more of the 
#' following: \code{id, snippet}. e.g., "id, snippet", "id" Default: \code{snippet}.  
#' @param video_id ID of the video whose captions are requested. Required. No default.
#' @param lang  Language of the caption; required; default is english ("en")
#' @param id    comma-separated list of IDs that identify the caption resources that should be retrieved; optional; string
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' 
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/captions/list}
#' 
#' @examples
#' \dontrun{
#' get_captions(video_id="yJXTXN4xrI8")
#' }

get_captions <- function (part="snippet", video_id=NULL, lang="en", id=NULL, ...) {

	if (is.null(video_id)) stop("Must specify a video ID")

	yt_check_token()

	# Try getting captions directly
	req <- GET(paste0("http://video.google.com/timedtext?lang=", lang, "&v=", video_id))
	req <- content(req)

	# If not try other things
	if (length(req)==0) {
		
		querylist = list(part=part, videoId = video_id, id = id)
		req <- tuber_GET("captions", query = querylist, ...)
		
		# Multiple caption tracks possible but for now harvest just the first
		caption_id <- req$items[[1]]$id

		caption <- tuber_GET("captions", query=list(part=part, videoId = video_id, id = caption_id), ...)

		return(caption)
	}

	req
}
