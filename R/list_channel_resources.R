#' Returns List of Requested Channel Resources
#' 
#' @param channel_name string, channel name, required
#' @param part a comma separated list of channel resource properties that response will include
#' string, required, one of the following: auditDetails, brandingSettings, contentDetails, contentOwnerDetails, id, invideoPromotion, localizations, snippet, statistics, status, topicDetails
#' default is contentDetails
#' @param hl  language that will be used for text values, optional, default is en-US. See also \code{\link{list_langs}}
#' @param max_results maximum number of items that should be returned, integer, can be between 0 and 50, default is 50
#' @param page_token specific page in the result set that should be returned, optional
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return list
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' @examples
#' \dontrun{
#' list_channel_videos("latenight")
#' list_channel_videos("latenight", part="id, contentDetails")
#' list_channel_videos("latenight", part="id, contentDetails", max_results=10)
#' }

list_channel_resources <- function (channel_name=NULL, part="contentDetails", max_results = 50, page_token = NULL, ...) 
{
     querylist <- list(part = part, forUsername = channel_name, max_results = max_results, page_token = page_token)
     res <- tuber_GET("channels", querylist, ...)
    
     return(invisible(res))
}

