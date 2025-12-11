#' Search YouTube
#'
#' Search for videos, channels and playlists. (By default, the function
#' searches for videos.)
#'
#' @param term Character. Search term; required; no default
#' For using Boolean operators, see the API documentation.
#' Here's some of the relevant information:
#' "Your request can also use the Boolean NOT (-) and OR (|) operators to
#' exclude videos or to
#' find videos that are associated with one of several search terms. For
#' example, to search
#' for videos matching either "boating" or "sailing", set the q parameter
#' value to boating|sailing.
#' Similarly, to search for videos matching either "boating" or "sailing"
#' but not "fishing",
#' set the q parameter value to boating|sailing -fishing"
#' @param max_results Maximum number of items that should be returned in total.
#' Integer. Optional. Can be between 1 and 500. Default is 50. If
#' \code{get_all = TRUE}, multiple API calls are made until this many
#' results are collected (subject to YouTube limits). Requesting a large number
#' of results will consume more API quota. Search results are
#' constrained to a maximum of 500 videos if type is video and we have a
#' value of \code{channel_id}.
#' @param channel_id Character. Only return search results from this
#' channel; Optional.
#' @param channel_type Character. Optional. Takes one of two values:
#' \code{'any', 'show'}. Default is \code{'any'}
#' @param event_type Character. Optional. Takes one of three values:
#' \code{'completed', 'live', 'upcoming'}
#' @param location  Character.  Optional. Latitude and Longitude within
#' parentheses, e.g. "(37.42307,-122.08427)"
#' @param location_radius Character.  Optional. e.g. "1500m", "5km",
#' "10000ft", "0.75mi"
#' @param published_after Character. Optional. RFC 339 Format.
#' For instance, "1970-01-01T00:00:00Z"
#' @param published_before Character. Optional. RFC 339 Format.
#' For instance, "1970-01-01T00:00:00Z"
#' @param relevance_language Character. Optional. The relevance_language
#' argument instructs the API to return search results that are most relevant to
#' the specified language. The parameter value is typically an ISO 639-1
#' two-letter language code. However, you should use the values zh-Hans for
#' simplified Chinese and zh-Hant for traditional Chinese. Please note that
#' results in other languages will still be returned if they are highly relevant
#' to the search query term.
#' @param type Character. Optional. Takes one of three values:
#' \code{'video', 'channel', 'playlist'}. Default is \code{'video'}.
#' @param video_caption Character. Optional. Takes one of three values:
#' \code{'any'} (return all videos; Default), \code{'closedCaption', 'none'}.
#' Type must be set to video.
#' @param video_type Character. Optional. Takes one of three values:
#' \code{'any'} (return all videos; Default), \code{'episode'}
#' (return episode of shows), 'movie' (return movies)
#' @param video_syndicated Character. Optional. Takes one of two values:
#' \code{'any'} (return all videos; Default), \code{'true'}
#' (return only syndicated videos)
#' @param region_code Character. Required. Has to be a ISO 3166-1 alpha-2 code
#'  (see \url{https://www.iso.org/obp/ui/#search}).
#' @param video_definition Character. Optional.
#' Takes one of three values: \code{'any'} (return all videos; Default),
#' \code{'high', 'standard'}
#' @param video_license Character. Optional.
#' Takes one of three values: \code{'any'} (return all videos; Default),
#' \code{'creativeCommon'} (return videos with Creative Commons
#' license), \code{'youtube'} (return videos with standard YouTube license).
#' @param simplify Boolean. Return a data.frame if \code{TRUE}.
#' Default is \code{TRUE}.
#' If \code{TRUE}, it returns a list that carries additional information.
#' @param page_token specific page in the result set that should be
#' returned, optional
#' @param get_all get all results, iterating through all the results
#' pages. Default is \code{TRUE}.
#' Result is a \code{data.frame}. Optional.
#' @param max_pages Maximum number of pages to retrieve when get_all is TRUE.
#' Default is Inf (no page limit). Setting a lower value can reduce API quota
#' usage.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return data.frame with 16 elements: \code{video_id, publishedAt,
#' channelId, title, description,
#' thumbnails.default.url, thumbnails.default.width, thumbnails.default.height,
#' thumbnails.medium.url,
#' thumbnails.medium.width, thumbnails.medium.height, thumbnails.high.url,
#' thumbnails.high.width,
#' thumbnails.high.height, channelTitle, liveBroadcastContent}
#' The returned data.frame also has the following attributes:
#' \code{total_results}: The total number of results reported by the API
#' \code{actual_results}: The actual number of rows returned
#' \code{api_limit_reached}: Whether the YouTube API result limit was reached
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#'
#' @examples
#'
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' yt_search(term = "Barack Obama")
#' yt_search(term = "Barack Obama", published_after = "2016-10-01T00:00:00Z")
#' yt_search(term = "Barack Obama", published_before = "2016-09-01T00:00:00Z")
#' yt_search(term = "Barack Obama", published_before = "2016-03-01T00:00:00Z",
#'                                published_after = "2016-02-01T00:00:00Z")
#' yt_search(term = "Barack Obama", published_before = "2016-02-10T00:00:00Z",
#'                                published_after = "2016-01-01T00:00:00Z")
#'
#' # To check how many results were found vs. how many were returned:
#' results <- yt_search(term = "drone videos")
#' attr(results, "total_results")  # Total number reported by YouTube
#' attr(results, "actual_results") # Number actually returned
#' attr(results, "api_limit_reached") # Whether API limit was reached
#' }

yt_search <- function(term = NULL, max_results = 50, channel_id = NULL,
                      channel_type = NULL, type = "video", event_type = NULL,
                      location = NULL, location_radius = NULL,
                      published_after = NULL, published_before = NULL,
                      video_definition = "any", video_caption = "any",
                      video_license = "any", video_syndicated = "any",
                      region_code = NULL, relevance_language = "en",
                      video_type = "any", simplify = TRUE, get_all = TRUE,
                      page_token = NULL, max_pages = Inf, ...) {

  # Modern validation using checkmate
  assert_string(term, min.chars = 1, .var.name = "term")
  assert_integerish(max_results, len = 1, lower = 1, upper = 500, .var.name = "max_results")
  assert_choice(type, c("video", "channel", "playlist"), .var.name = "type")
  assert_logical(simplify, len = 1, .var.name = "simplify")
  assert_logical(get_all, len = 1, .var.name = "get_all")
  assert_numeric(max_pages, len = 1, lower = 1, .var.name = "max_pages")

  # Validate video-specific parameters only when type is "video"
  if (type == "video") {
    assert_choice(video_license, c("any", "creativeCommon", "youtube"), .var.name = "video_license")
    assert_choice(video_syndicated, c("any", "true"), .var.name = "video_syndicated")
    assert_choice(video_type, c("any", "episode", "movie"), .var.name = "video_type")
    assert_choice(video_definition, c("any", "high", "standard"), .var.name = "video_definition")
    assert_choice(video_caption, c("any", "closedCaption", "none"), .var.name = "video_caption")
  } else {
    # Set these to NULL if type is not "video" to avoid sending them in the API call
    video_caption <- video_license <- video_definition <-
      video_type <- video_syndicated <- NULL
  }

  # Modern RFC 3339 date validation using rlang
  validate_rfc339_date <- function(date_str, param_name) {
    if (is.character(date_str) &&
        is.na(as.POSIXct(date_str, format = "%Y-%m-%dT%H:%M:%SZ"))) {
      abort("Invalid RFC 3339 date format",
            parameter = param_name,
            date_string = date_str,
            expected_format = "YYYY-MM-DDTHH:MM:SSZ",
            example = "2023-01-01T00:00:00Z",
            class = "tuber_invalid_date_format")
    }
  }

  validate_rfc339_date(published_after, "published_after")
  validate_rfc339_date(published_before, "published_before")

  # Validate location and location_radius together
  if (!is.null(location) && is.null(location_radius)) {
    abort("Location radius required when location is specified",
          location = location,
          help = "Provide location_radius parameter (e.g., '10km')",
          class = "tuber_missing_location_radius")
  }

  # Build the query list
  results_per_page <- min(max_results, 50)
  querylist <- list(
    part = "snippet",
    q = term,
    maxResults = results_per_page,
    channelId = channel_id,
    type = type,
    channelType = channel_type,
    eventType = event_type,
    location = location,
    locationRadius = location_radius,
    publishedAfter = published_after,
    publishedBefore = published_before,
    videoDefinition = video_definition,
    videoCaption = video_caption,
    videoType = video_type,
    videoSyndicated = video_syndicated,
    videoLicense = video_license,
    regionCode = region_code,
    relevanceLanguage = relevance_language,
    pageToken = page_token
  )

  # Remove NULL values
  querylist <- querylist[!sapply(querylist, is.null)]

  # Helper function to process search results
  process_results <- function(res_items, item_type) {
    if (length(res_items) == 0) {
      return(data.frame())
    }

    if (item_type == "video") {
      simple_res <- lapply(res_items, function(x) {
        if (is.null(x$id$videoId)) {
          return(NULL)  # Skip items without videoId
        }
        c(video_id = x$id$videoId, unlist(x$snippet))
      })
    } else {
      simple_res <- lapply(res_items, function(x) unlist(x$snippet))
    }

    # Remove NULL entries and convert to data frame
    simple_res <- simple_res[!sapply(simple_res, is.null)]
    if (length(simple_res) == 0) {
      return(data.frame())
    }

    return(ldply(simple_res, rbind))
  }

  # Make initial API call
  res <- tuber_GET("search", querylist, ...)

  # If get_all is FALSE or there are no results, process and return
  if (!identical(get_all, TRUE) || res$pageInfo$totalResults == 0) {
    if (!identical(simplify, TRUE)) {
      return(res)
    }
    return(process_results(res$items, type))
  }

  # Process all pages for get_all=TRUE
  all_results <- process_results(res$items, type)
  page_token <- res$nextPageToken
  page_count <- 1
  total_returned <- nrow(all_results)

  # Get all pages up to max_pages limit and requested max_results
  while (!is.null(page_token) && page_count < max_pages &&
         total_returned < max_results) {
    
    # Calculate how many more results we actually need
    remaining_needed <- max_results - total_returned
    request_size <- min(remaining_needed, 50)  # Don't request more than we need
    
    querylist$pageToken <- page_token
    querylist$maxResults <- request_size
    a_res <- tuber_GET("search", querylist, ...)

    next_results <- process_results(a_res$items, type)
    
    # Only take what we need if we get more than requested
    if (nrow(next_results) > remaining_needed) {
      next_results <- next_results[seq_len(remaining_needed), , drop = FALSE]
    }
    
    all_results <- rbind(all_results, next_results)
    total_returned <- nrow(all_results)
    page_token <- a_res$nextPageToken
    page_count <- page_count + 1

    # Stop if we've reached our target
    if (total_returned >= max_results) {
      break
    }

    # Check if we've reached YouTube's limit (around 500-600 items)
    if (total_returned >= 500 && is.null(page_token)) {
      warning("Reached YouTube API search result limit (approximately 500 items)")
      break
    }
  }

  # Add warning if we hit the max_pages limit but there are still more results
  if (!is.null(page_token) && page_count >= max_pages && total_returned < max_results) {
    warning(sprintf("Only retrieved %d pages of results (got %d/%d items). Set max_pages higher to get more results.", 
                   max_pages, total_returned, max_results))
  }

  # Calculate actual API calls made
  api_calls_made <- page_count
  
  # Add standardized attributes (preserving existing ones)
  result <- add_tuber_attributes(
    all_results,
    api_calls_made = api_calls_made,
    function_name = "yt_search",
    parameters = list(
      term = term, 
      max_results = max_results, 
      type = type,
      get_all = get_all,
      max_pages = max_pages
    ),
    results_found = nrow(all_results),
    pages_retrieved = page_count,
    search_exhausted = is.null(page_token) || page_count >= max_pages
  )
  
  # Preserve existing attributes
  attr(result, "total_results") <- res$pageInfo$totalResults
  attr(result, "actual_results") <- nrow(all_results) 
  attr(result, "api_limit_reached") <- nrow(all_results) >= 500

  return(result)
}
