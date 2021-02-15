#' Get Details of a Video or Videos
#'
#' Get details such as when the video was published, the title, description,
#' thumbnails, category etc.
#'
#' @param video_id Comma separated list of IDs of the videos for which
#' details are requested. Required.
#' @param part Comma-separated list of video resource properties requested.
#' Options include:
#' \code{contentDetails, fileDetails, id, liveStreamingDetails,
#' localizations, player, processingDetails,
#' recordingDetails, snippet, statistics, status, suggestions, topicDetails}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return list. If part is snippet, the list will have the following elements:
#' \code{id} (video id that was passed), \code{publishedAt, channelId,
#'  title, description, thumbnails,
#' channelTitle, categoryId, liveBroadcastContent, localized,
#' defaultAudioLanguage}
#'
#' @export

#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list}

#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_video_details(video_id = "yJXTXN4xrI8")
#' get_video_details(video_id = "yJXTXN4xrI8", part = "contentDetails")
#' }

get_video_details <- function(video_id = NULL, part = "snippet", ...) {

  if (!is.character(video_id)) stop("Must specify a video ID.")

  querylist <- list(part = part, id = video_id)

  raw_res <- tuber_GET("videos",  querylist, ...)

  if (length(raw_res$items) == 0) {
      warning("No details for this video are available. Likely cause:
              Incorrect ID. \n")
      return(list())
    }

  raw_res
}
