# helpers for data frame conversion in `get_video_details()`
conditional_unnest_wider <- function(data_input, var) {
  if (var %in% names(data_input)) {
    tidyr::unnest_wider(data_input, var, names_sep = "_")
  } else {
    data_input
  }
}

# Added to squash notes on devtools check.
utils::globalVariables(c("kind", "etag", "items", "snippet"))

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
#' recordingDetails, snippet, statistics, status, suggestions, topicDetails}.
#' Note: As of October 30, 2024, the \code{status} part includes 
#' \code{containsSyntheticMedia} property for identifying AI-generated content.
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
#' 
#' # Extract specific fields (common use case):
#' details <- get_video_details(video_id = "yJXTXN4xrI8")
#' # Get video title:
#' video_title <- details$items[[1]]$snippet$title
#' # Get video description:  
#' video_desc <- details$items[[1]]$snippet$description
#' 
#' # Shiny usage - extract video title safely:
#' # output$videotitle <- renderText({
#' #   details <- get_video_details(input$commentkey)
#' #   if (length(details$items) > 0) {
#' #     details$items[[1]]$snippet$title
#' #   } else {
#' #     "Video not found"
#' #   }
#' # })
#' # Get channel ID:
#' channel_id <- details$items[[1]]$snippet$channelId
#' 
#' # For Shiny applications - extract title:
#' # output$videotitle <- renderText({ 
#' #   details <- get_video_details(input$video_id)
#' #   if (length(details$items) > 0) {
#' #     details$items[[1]]$snippet$title
#' #   } else {
#' #     "Video not found"
#' #   }
#' # })
#' 
#' # Check for AI-generated content (requires status part):
#' # status_details <- get_video_details(video_id = "yJXTXN4xrI8", part = "status")
#' # is_synthetic <- status_details$items[[1]]$status$containsSyntheticMedia
#' }
#'
get_video_details <- function(video_id = NULL, part = "snippet", as.data.frame = FALSE, batch_size = 50, use_etag = TRUE, ...) {
  # Modern validation using checkmate
  assert_character(video_id, any.missing = FALSE, min.len = 1, .var.name = "video_id")
  assert_character(part, len = 1, min.chars = 1, .var.name = "part")
  assert_logical(as.data.frame, len = 1, .var.name = "as.data.frame")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  
  # AUTOMATIC BATCHING: If multiple video IDs provided, use batch operations
  if (length(video_id) > 1) {
    message("Multiple video IDs detected. Using automatic batch processing for efficiency.")
    return(get_videos_batch(
      video_ids = video_id,
      part = part,
      batch_size = batch_size,
      simplify = as.data.frame,
      show_progress = length(video_id) > 10,
      ...
    ))
  }
  
  parts_only_for_video_owners <- c("fileDetails", "suggestions", "processingDetails")

  if (as.data.frame && any(part %in% parts_only_for_video_owners)) {
    abort("Data frame conversion not supported with owner-only parts",
          owner_only_parts = parts_only_for_video_owners,
          requested_parts = part,
          help = "Use as.data.frame = FALSE for owner-only parts",
          class = "tuber_incompatible_dataframe_parts")
  }

  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }

  if (length(video_id) > 1) {
    video_id <- paste0(video_id, collapse = ",")
  }

  querylist <- list(part = part, id = video_id)

  # Handle API call with retry logic
  raw_res <- call_api_with_retry(
    tuber_GET, 
    path = "videos", 
    query = querylist,
    ...
  )

  if (length(raw_res$items) == 0) {
    suggest_solution("empty_results", "- Check if the video ID is correct\n- Video may be private or deleted")
    warning("No video details found for ID: ", video_id, call. = FALSE)
    
    # Add attributes even to empty results for consistency
    empty_result <- list()
    return(add_tuber_attributes(
      empty_result,
      api_calls_made = 1,
      function_name = "get_video_details",
      parameters = list(video_id = video_id, part = part, as.data.frame = as.data.frame),
      results_found = 0
    ))
  }

  if (as.data.frame) {
    raw_res <- purrr::map_df(raw_res$items, ~ flatten(.x))
  }

  # Add standardized attributes
  result <- add_tuber_attributes(
    raw_res,
    api_calls_made = 1,
    function_name = "get_video_details", 
    parameters = list(video_id = video_id, part = part, as.data.frame = as.data.frame),
    results_found = length(raw_res$items %||% nrow(raw_res)),
    response_format = if (as.data.frame) "data.frame" else "list"
  )
  
  result
}

