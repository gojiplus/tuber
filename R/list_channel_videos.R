#' Returns List of Requested Channel Videos
#' 
#' @param channel_id String. ID of the channel. Required. 
#' @param max_results Maximum number of items that should be returned. Integer. Optional. Can be between 0 and 50. Default is 50.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return character vector
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' 
#' @examples
#' 
#' \dontrun{
#' list_channel_videos(channel_id = "UCT5Cx1l4IS3wHkJXNyuj4TA")
#' list_channel_videos(channel_id = "UCT5Cx1l4IS3wHkJXNyuj4TA", max_results=10)
#' }

list_channel_videos <- function (channel_id=NULL, max_results = 50, ...) 
{

	if (is.null(channel_id)) stop("Must specify a channel ID")

    querylist <- list(id = channel_id, part="contentDetails", maxResults= max_results)

    res <- tuber_GET("channels", querylist, ...)
    
	# Uploaded playlists:
	playlist_id <- res$items[[1]]$contentDetails$relatedPlaylists$uploads

	# Get videos on the playlist
	vids <- get_playlist_items(filter= c(playlist_id=playlist_id)) 

	# Video ids
	vid_ids <- as.vector(unlist(sapply(vids$items, "[", "contentDetails")))

    return(invisible(vid_ids))
}

