#' YouTube API Quota Management
#' 
#' Functions to track and manage YouTube API quota usage
#' @name quota_management
NULL

# Global environment for quota tracking
.tuber_env <- new.env(parent = emptyenv())
.tuber_env$quota_used <- 0
.tuber_env$quota_limit <- 10000  # Default daily limit
.tuber_env$quota_reset_time <- as.POSIXct(Sys.Date() + 1)  # Midnight UTC
.tuber_env$request_times <- numeric(0)

#' Get Current Quota Usage
#' 
#' Returns the current estimated quota usage for the day
#' 
#' @return List with quota_used, quota_limit, quota_remaining, and reset_time
#' @export
#' 
#' @examples 
#' \dontrun{
#' quota_status <- yt_get_quota_usage()
#' cat("Used:", quota_status$quota_used, "/", quota_status$quota_limit)
#' }
yt_get_quota_usage <- function() {
  # Reset quota if it's a new day
  if (Sys.time() > .tuber_env$quota_reset_time) {
    yt_reset_quota()
  }
  
  list(
    quota_used = .tuber_env$quota_used,
    quota_limit = .tuber_env$quota_limit,
    quota_remaining = max(0, .tuber_env$quota_limit - .tuber_env$quota_used),
    reset_time = .tuber_env$quota_reset_time,
    requests_last_minute = sum(.tuber_env$request_times > (Sys.time() - 60))
  )
}

#' Set Quota Limit
#' 
#' Set the daily quota limit (default is 10,000 units)
#' 
#' @param limit Integer. Daily quota limit in units
#' @export
#' 
#' @examples
#' \dontrun{
#' # If you have a higher quota limit
#' yt_set_quota_limit(50000)
#' }
yt_set_quota_limit <- function(limit) {
  if (!is.numeric(limit) || limit <= 0) {
    stop("Quota limit must be a positive number")
  }
  .tuber_env$quota_limit <- as.integer(limit)
  invisible(.tuber_env$quota_limit)
}

#' Reset Quota Counter
#' 
#' Reset the quota counter (typically done automatically at midnight UTC)
#' 
#' @export
yt_reset_quota <- function() {
  .tuber_env$quota_used <- 0
  .tuber_env$quota_reset_time <- as.POSIXct(Sys.Date() + 1)
  .tuber_env$request_times <- numeric(0)
  invisible(NULL)
}

#' Track Quota Usage
#' 
#' Internal function to track API usage
#' 
#' @param endpoint Character. API endpoint name
#' @param parts Character vector. Parts requested
#' @param additional_cost Integer. Additional cost for complex operations
#' 
#' @keywords internal
track_quota_usage <- function(endpoint, parts = NULL, additional_cost = 0) {
  # Reset quota if it's a new day
  if (Sys.time() > .tuber_env$quota_reset_time) {
    yt_reset_quota()
  }
  
  # Calculate cost based on endpoint and parts
  base_costs <- list(
    search = 100,          # Search operations are expensive
    videos = 1,            # Video details
    channels = 1,          # Channel details  
    playlists = 1,         # Playlist details
    playlistItems = 1,     # Playlist items
    commentThreads = 1,    # Comment threads
    comments = 1,          # Individual comments
    captions = 50,         # Caption operations
    channelSections = 1    # Channel sections
  )
  
  # Base cost for the endpoint
  cost <- base_costs[[endpoint]] %||% 1
  
  # Add part-based costs (some parts are more expensive)
  if (!is.null(parts)) {
    expensive_parts <- c("statistics", "contentDetails", "topicDetails", "recordingDetails")
    part_list <- strsplit(parts, ",")[[1]]
    part_list <- trimws(part_list)
    expensive_count <- sum(part_list %in% expensive_parts)
    cost <- cost + expensive_count
  }
  
  # Add any additional cost
  cost <- cost + additional_cost
  
  # Track the usage
  .tuber_env$quota_used <- .tuber_env$quota_used + cost
  .tuber_env$request_times <- c(.tuber_env$request_times, as.numeric(Sys.time()))
  
  # Keep only last hour of request times for rate limiting
  one_hour_ago <- as.numeric(Sys.time() - 3600)
  .tuber_env$request_times <- .tuber_env$request_times[.tuber_env$request_times > one_hour_ago]
  
  # Check for quota exhaustion
  quota_status <- yt_get_quota_usage()
  
  if (quota_status$quota_remaining <= 0) {
    warning("YouTube API quota limit reached (", .tuber_env$quota_used, "/", .tuber_env$quota_limit, 
            "). Quota resets at ", format(.tuber_env$quota_reset_time, "%Y-%m-%d %H:%M:%S UTC"))
  } else if (quota_status$quota_remaining <= 100) {
    warning("YouTube API quota nearly exhausted (", quota_status$quota_remaining, " units remaining)")
  }
  
  # Rate limiting check (basic)
  if (quota_status$requests_last_minute > 50) {
    message("High request rate detected. Consider adding delays between API calls.")
  }
  
  invisible(cost)
}

#' Add Exponential Backoff
#' 
#' Internal function to handle rate limiting with exponential backoff
#' 
#' @param attempt_number Integer. Current attempt number
#' @param max_attempts Integer. Maximum attempts before giving up
#' @param base_delay Numeric. Base delay in seconds
#' 
#' @keywords internal
exponential_backoff <- function(attempt_number, max_attempts = 5, base_delay = 1) {
  if (attempt_number > max_attempts) {
    stop("Maximum retry attempts (", max_attempts, ") exceeded")
  }
  
  if (attempt_number > 1) {
    delay <- base_delay * (2 ^ (attempt_number - 2))  # 1, 2, 4, 8 seconds...
    delay <- delay + runif(1, 0, 0.5)  # Add jitter
    message("Rate limited. Waiting ", round(delay, 2), " seconds before retry...")
    Sys.sleep(delay)
  }
}