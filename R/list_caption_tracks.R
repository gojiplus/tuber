#' Get Captions of a Video
#' 
#' @param part  Caption resource requested. Required. Comma separated list of one or more of the 
#' following: \code{id, snippet}. e.g., "id, snippet", "id" Default: \code{snippet}.  
#' @param video_id ID of the video whose captions are requested. Required. No default.
#' @param lang  Language of the caption; required; default is english ("en")
#' @param id    comma-separated list of IDs that identify the caption resources that should be retrieved; optional; string
#' @param simplify Boolean. Default is TRUE. When TRUE, and part is \code{snippet}, a data.frame is returned
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return list of caption tracks. When simplify is TRUE, a data.frame is returned with 
#' following columns: videoId, lastUpdated, trackKind, language, name, audioTrackType, isCC,
#' isLarge, isEasyReader, isDraft, isAutoSynced, status, id (caption id)
#' 
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/captions/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' list_caption_tracks(video_id="yJXTXN4xrI8")
#' }

list_caption_tracks <- function (part="snippet", video_id=NULL, lang="en", id = NULL, simplify = TRUE, ...) {

	if (!is.character(video_id)) stop("Must specify a video ID.")
	
	querylist = list(part=part, videoId = video_id, id = id)
	raw_res <- tuber_GET("captions", query = querylist, ...)
		
	if (length(raw_res$items) ==0) { 
    	cat("No caption tracks available. Likely cause: Incorrect video ID. \n")
    	return(list())
    }

    if (simplify == TRUE & part=="snippet") {
    	res_df 	  <- as.data.frame(do.call(rbind, lapply(raw_res$items, function(x) unlist(x$snippet))))
    	res_df$id <- sapply(raw_res$items, function(x) unlist(x$id))
    	return(res_df)
    }

	raw_res
}

