#' Returns List of Requested Channel Resources
#' 
#' @param channel_name string, channel name, required
#' @param part a comma separated list of channel resource properties that response will include
#' string, required, one of the following: auditDetails, brandingSettings, contentDetails, contentOwnerDetails, id, invideoPromotion, localizations, snippet, statistics, status, topicDetails
#' default is contentDetails
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return list
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' @examples
#' \dontrun{
#' list_channel_videos("latenight")
#' list_channel_videos("latenight", part="id, contentDetails")
#' }

list_channel_resources <- function (channel_name=NULL, part="contentDetails",...) 
{
     querylist <- list(part = part, forUsername = channel_name)
     res <- tuber_GET("channels", querylist, ...)
    
     return(invisible(res))
}

