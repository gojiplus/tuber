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
#' @param max_results Maximum number of items that should be returned.
#' Integer. Optional. Can be between 0 and 50. Default is 50.
#' Search results are constrained to a maximum of 500 videos if type is
#' video and we have a value of \code{channel_id}.
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
#' Default is 10. Set higher for more results, but be aware of API quota limits.
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
                      page_token = NULL, max_pages = 10, ...) {

  # Input validation
  if (!is.character(term) || is.null(term)) stop("Must specify a search term.\n")

  if (max_results < 0 || max_results > 50) {
    stop("max_results only takes a value between 0 and 50.")
  }

  # Validate video-specific parameters only when type is "video"
  if (type == "video") {
    if (!(video_license %in% c("any", "creativeCommon", "youtube"))) {
      stop("video_license can only take values: any, creativeCommon, or youtube.")
    }

    if (!(video_syndicated %in% c("any", "true"))) {
      stop("video_syndicated can only take values: any or true.")
    }

    if (!(video_type %in% c("any", "episode", "movie"))) {
      stop("video_type can only take values: any, episode, or movie.")
    }
  } else {
    # Set these to NULL if type is not "video" to avoid sending them in the API call
    video_caption <- video_license <- video_definition <-
      video_type <- video_syndicated <- NULL
  }

  # Validate date formats
  validate_rfc339_date <- function(date_str) {
    if (is.character(date_str) &&
        is.na(as.POSIXct(date_str, format = "%Y-%m-%dT%H:%M:%SZ"))) {
      stop("The date is not properly formatted in RFC 339 Format (YYYY-MM-DDTHH:MM:SSZ).")
    }
  }

  validate_rfc339_date(published_after)
  validate_rfc339_date(published_before)

  # Validate location and location_radius together
  if (!is.null(location) && is.null(location_radius)) {
    stop("Location radius must be specified with location")
  }

  # Build the query list
  querylist <- list(
    part = "snippet",
    q = term,
    maxResults = max_results,
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

  # Get all pages up to max_pages limit
  while (!is.null(page_token) && page_count < max_pages) {
    querylist$pageToken <- page_token
    a_res <- tuber_GET("search", querylist, ...)

    next_results <- process_results(a_res$items, type)
    all_results <- rbind(all_results, next_results)
    page_token <- a_res$nextPageToken
    page_count <- page_count + 1

    # Check if we've reached YouTube's limit (around 500-600 items)
    if (nrow(all_results) >= 500 && is.null(page_token)) {
      warning("Reached YouTube API search result limit (approximately 500 items)")
      break
    }
  }

  # Add warning if we hit the max_pages limit but there are still more results
  if (!is.null(page_token) && page_count >= max_pages) {
    warning(sprintf("Only retrieved %d pages of results. Set max_pages higher to get more results.", max_pages))
  }

  # Add additional information as attributes
  attr(all_results, "total_results") <- res$pageInfo$totalResults
  attr(all_results, "actual_results") <- nrow(all_results)
  attr(all_results, "api_limit_reached") <- nrow(all_results) >= 500

  return(all_results)
}
