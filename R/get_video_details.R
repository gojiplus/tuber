# helpers for `get_video_details()`
conditional_unnest_wider <- function(data_input, var) {
  if (var %in% names(data_input)) {
    tidyr::unnest_wider(data_input, var, names_sep = "_")
  } else {
    data_input
  }
}


json_to_df <- function(res) {
  intermediate <- res %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest(cols = c(kind, etag)) %>%
    # reflect level of nesting in column name
    dplyr::rename(response_kind = kind, response_etag = etag) %>%
    tidyr::unnest(items) %>%
    tidyr::unnest_wider(col = items) %>%
    # reflect level of nesting in column name for those that may not be unique
    dplyr::rename(items_kind = kind, items_etag = etag) %>%
    tidyr::unnest_wider(snippet)

  intermediate_2 <- intermediate %>%
    # fields that may not be available:
    # live streaming details
    conditional_unnest_wider(var = "liveStreamingDetails") %>%
    # region restriction (rental videos)
    conditional_unnest_wider(var = "regionRestriction") %>%
    conditional_unnest_wider(var = "regionRestriction_allowed") %>%
    # statistics
    conditional_unnest_wider(var = "statistics") %>%
    # status
    conditional_unnest_wider(var = "status") %>%
    # player
    conditional_unnest_wider(var = "player") %>%
    # contentDetails
    conditional_unnest_wider(var = "contentDetails") %>%
    conditional_unnest_wider(var = "topicDetails") %>%
    conditional_unnest_wider(var = "localized") %>%
    conditional_unnest_wider(var = "pageInfo") %>%
    # thumbnails
    conditional_unnest_wider(var = "thumbnails") %>%
    conditional_unnest_wider(var = "thumbnails_default") %>%
    conditional_unnest_wider(var = "thumbnails_standard") %>%
    conditional_unnest_wider(var = "thumbnails_medium") %>%
    conditional_unnest_wider(var = "thumbnails_high") %>%
    conditional_unnest_wider(var = "thumbnails_maxres")


  intermediate_2
}

#' Get Details of a Video or Videos
#'
#' Get details such as when the video was published, the title, description,
#' thumbnails, category etc.
#'
#' @param video_id Comma separated list of IDs of the videos for which
#' details are requested. Required.
#' @param part Comma-separated vector of video resource properties requested.
#' Options include:
#' \code{contentDetails, fileDetails, id, liveStreamingDetails,
#' localizations, player, processingDetails,
#' recordingDetails, snippet, statistics, status, suggestions, topicDetails}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' @param as.data.frame Logical, returns the requested information as data.frame.
#' Does not work for:
#' \code{fileDetails, suggestions, processingDetails}
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
#' # retrieve multiple parameters
#' get_video_details(video_id = "yJXTXN4xrI8", part = c("contentDetails", "status"))
#' # get details for multiple videos as data frame
#' get_video_details(video_id = c("LDZX4ooRsWs", "yJXTXN4xrI8"), as.data.frame = TRUE)
#' }
#'
get_video_details <- function(video_id = NULL, part = "snippet", as.data.frame = FALSE, ...) {
  if (!is.character(video_id)) stop("Must specify a video ID.")

  if (!is.character(part)) stop("Parameter part must be a character vector")

  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }

  if (length(video_id) > 1) {
    video_id <- paste0(video_id, collapse = ",")
  }

  parts_only_for_video_owners <- c("fileDetails", "suggestions", "processingDetails")

  if (as.data.frame & part %in% parts_only_for_video_owners) {
    stop(
      paste("If as.data.frame = TRUE, then `part` may not include any of the following parts: "),
      paste(parts_only_for_video_owners, collapse = " ,")
    )
  }

  querylist <- list(part = part, id = video_id)

  raw_res <- tuber_GET("videos", querylist, ...)

  if (length(raw_res$items) == 0) {
    warning("No details for this video are available. Likely cause:
              Incorrect ID. \n")
    return(list())
  }

  if (as.data.frame) {
    raw_res <- json_to_df(raw_res)
  }

  raw_res
}
