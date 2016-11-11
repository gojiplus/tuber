#' Get Playlists
#' 
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector: 
#' \code{channel_id}: ID of the channel
#' \code{playlist_id}: YouTube playlist ID.
#' 
#' @param part Required. One of the following: \code{contentDetails, id, localizations, player, snippet, status}. Default: \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned. Integer. Optional. Can be between 0 and 50. Default is 50.
#' @param page_token specific page in the result set that should be returned, optional
#' @param hl  Language used for text values. Optional. Default is \code{en-US}. For other allowed language codes, see \code{\link{list_langs}}.
#' @param simplify Data Type: Boolean. Default is \code{TRUE}. If \code{TRUE} and if part requested is \code{contentDetails}, 
#' the function returns a \code{data.frame}. Else a list with all the information returned.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/list}
#' 
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' get_playlists(filter=c(channel_id="UCMtFAi84ehTSYSE9XoHefig"))
#' get_playlists(filter=c(channel_id="UCMtFAi84ehTSYSE9X")) # incorrect Channel ID
#' }

get_playlists <- function (filter=NULL, part="contentDetails", max_results=50, hl = NULL, page_token=NULL, simplify = TRUE, ...) {

	if (max_results < 0 | max_results > 50) stop("max_results only takes a value between 0 and 50.")

	if (!(names(filter) %in% c("channel_id", "playlist_id"))) stop("filter can only take one of values: channel_id, playlist_id.")
	if ( length(filter) != 1) stop("filter must be a vector of length 1.\n")

	translate_filter   <- c(channel_id = 'channelId', playlist_id ='id')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	names(filter)      <- yt_filter_name

	querylist <- list(part=part, maxResults = max_results, pageToken = page_token, hl = hl)
	querylist <- c(querylist, filter)

	raw_res <- tuber_GET("playlists", querylist, ...)
 	
 	if (length(raw_res$items) ==0) { 
    	cat("No playlists available.\n")
    	if (simplify == TRUE) return(data.frame())
    	return(list())
    }

    if (simplify==TRUE & part=="contentDetails") {
		simple_res  <- lapply(raw_res$items, function(x) unlist(x))
		simpler_res <- as.data.frame(do.call(rbind, simple_res))
		return(simpler_res)
	} 

 	raw_res

}
