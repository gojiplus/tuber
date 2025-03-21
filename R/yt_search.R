yt_search <- function(term = NULL, max_results = 50, channel_id = NULL,
                      channel_type = NULL, type = "video", event_type = NULL,
                      location = NULL, location_radius = NULL,
                      published_after = NULL, published_before = NULL,
                      video_definition = "any", video_caption = "any",
                      video_license = "any", video_syndicated = "any",
                      region_code = NULL, relevance_language = "en",
                      video_type = "any", simplify = TRUE, get_all = TRUE,
                      page_token = NULL, ...) {

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
    
    if (!(video_definition %in% c("any", "high", "standard"))) {
      stop("video_definition can only take values: any, high, or standard.")
    }
    
    if (!(video_caption %in% c("any", "closedCaption", "none"))) {
      stop("video_caption can only take values: any, closedCaption, or none.")
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
  
  # Function to get next page of results
  get_next_page <- function(token) {
    querylist$pageToken <- token
    a_res <- tuber_GET("search", querylist, ...)
    return(list(
      results = process_results(a_res$items, type),
      next_token = a_res$nextPageToken
    ))
  }
  
  # Get all pages
  while (!is.null(page_token)) {
    next_page <- get_next_page(page_token)
    all_results <- rbind(all_results, next_page$results)
    page_token <- next_page$next_token
  }
  
  return(all_results)
}
