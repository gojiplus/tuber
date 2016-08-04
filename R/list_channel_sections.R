#' List Channel Sections
#' 
#' Returns list of channel sections that channel id belongs to. 
#' 
#' @param channel_id id of the channel; required; no default
#' @param part specify which part do you want. It can only be one of the following: \code{contentDetails, id, localizations, snippet, targeting}. Default is \code{snippet}.
#' @param hl  language that will be used for text values, optional, default is en-US. See also \code{\link{list_langs}}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return captions for the video from one of the first track
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/activities/list}
#' @examples
#' \dontrun{
#' list_channel_sections(channel_id="UCRw8bIz2wMLmfgAgWm903cA")
#' }

list_channel_sections <- function (channel_id=NULL, part="snippet", hl = NULL, ...) {

	
	if (is.null(channel_id)) stop("Must specify a channel_id")

	querylist <- list(part=part, channelId=channel_id)

	res <- tuber_GET("channelSections", querylist, ...)
 
 	res
}
