#' List Channel Sections
#' 
#' Returns list of channel sections that channel id belongs to. 
#' 
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector: 
#' \code{channel_id}: Channel ID
#' \code{id}: Section ID 
#'
#' @param part specify which part do you want. It can only be one of the following: \code{contentDetails, id, localizations, snippet, targeting}. Default is \code{snippet}.
#' @param hl  language that will be used for text values, optional, default is en-US. See also \code{\link{list_langs}}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/activities/list}
#' @examples
#' 
#' \dontrun{
#' list_channel_sections(c(channel_id="UCRw8bIz2wMLmfgAgWm903cA"))
#' }

list_channel_sections <- function (filter=NULL, part="snippet", hl = NULL, ...) {

	translate_filter   <- c(id = 'id', channel_id = 'channelId')
	yt_filter_name     <- as.vector(translate_filter[match(names(filter), names(translate_filter))])
	names(filter)      <- yt_filter_name

	querylist <- list(part=part)
    querylist <- c(querylist, filter)

	res <- tuber_GET("channelSections", querylist, ...)
 
 	res
}
