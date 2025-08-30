#' Tuber Error Handling Utilities
#'
#' Standardized error handling functions for consistent error messages
#' and recovery strategies across the tuber package.
#'
#' @name error-handling
NULL

#' Validate required character parameters
#'
#' @param value The value to validate
#' @param name The parameter name for error messages
#' @param allow_empty Whether to allow empty strings
#' @return Invisible NULL if valid, stops execution if invalid
validate_character <- function(value, name, allow_empty = FALSE) {
  if (missing(value) || is.null(value)) {
    stop("Parameter '", name, "' is required and cannot be NULL.", call. = FALSE)
  }
  
  if (!is.character(value)) {
    stop("Parameter '", name, "' must be a character vector.", call. = FALSE)
  }
  
  if (length(value) != 1) {
    stop("Parameter '", name, "' must be a single character string.", call. = FALSE)
  }
  
  if (!allow_empty && nchar(value) == 0) {
    stop("Parameter '", name, "' cannot be empty.", call. = FALSE)
  }
  
  invisible(NULL)
}

#' Validate numeric parameters with range checking
#'
#' @param value The value to validate
#' @param name The parameter name for error messages
#' @param min Minimum allowed value
#' @param max Maximum allowed value
#' @param integer_only Whether value must be an integer
#' @return Invisible NULL if valid, stops execution if invalid
validate_numeric <- function(value, name, min = -Inf, max = Inf, integer_only = FALSE) {
  if (missing(value) || is.null(value)) {
    stop("Parameter '", name, "' is required and cannot be NULL.", call. = FALSE)
  }
  
  if (!is.numeric(value) || length(value) != 1) {
    stop("Parameter '", name, "' must be a single numeric value.", call. = FALSE)
  }
  
  if (is.na(value)) {
    stop("Parameter '", name, "' cannot be NA.", call. = FALSE)
  }
  
  if (integer_only && value != as.integer(value)) {
    stop("Parameter '", name, "' must be an integer.", call. = FALSE)
  }
  
  if (value < min || value > max) {
    stop("Parameter '", name, "' must be between ", min, " and ", max, ".", call. = FALSE)
  }
  
  invisible(NULL)
}

#' Validate that parameter matches allowed values
#'
#' @param value The value to validate
#' @param name The parameter name for error messages
#' @param allowed Vector of allowed values
#' @return Invisible NULL if valid, stops execution if invalid
validate_choice <- function(value, name, allowed) {
  if (missing(value) || is.null(value)) {
    stop("Parameter '", name, "' is required and cannot be NULL.", call. = FALSE)
  }
  
  if (length(value) != 1) {
    stop("Parameter '", name, "' must be a single value.", call. = FALSE)
  }
  
  if (!value %in% allowed) {
    stop("Parameter '", name, "' must be one of: ", paste(allowed, collapse = ", "), ".", call. = FALSE)
  }
  
  invisible(NULL)
}

#' Handle YouTube API errors with context-specific messages
#'
#' @param error_response The error response from the API
#' @param context_msg Additional context for the error
#' @param video_id Video ID if applicable for better error messages
#' @param channel_id Channel ID if applicable for better error messages
#' @return Stops execution with informative error message
handle_api_error <- function(error_response, context_msg = "", video_id = NULL, channel_id = NULL) {
  
  # Extract error details from response
  if (is.list(error_response) && !is.null(error_response$error)) {
    error_info <- error_response$error
    error_code <- error_info$code %||% "Unknown"
    error_reason <- error_info$errors[[1]]$reason %||% "Unknown"
    error_message <- error_info$message %||% "Unknown error"
    
    # Provide specific guidance based on error type
    guidance <- switch(error_reason,
      "videoNotFound" = paste0(
        "Video '", video_id %||% "unknown", "' not found. ",
        "It may be private, deleted, or the ID is incorrect."
      ),
      "channelNotFound" = paste0(
        "Channel '", channel_id %||% "unknown", "' not found. ",
        "It may be private, deleted, or the ID is incorrect."
      ),
      "quotaExceeded" = paste0(
        "YouTube API quota exceeded. Try again later or check your quota usage with yt_get_quota_usage()."
      ),
      "commentsDisabled" = paste0(
        "Comments are disabled for this video."
      ),
      "forbidden" = paste0(
        "Access forbidden. Check your authentication credentials and API permissions."
      ),
      # Default message
      error_message
    )
    
    context_part <- if (nchar(context_msg) > 0) paste0(context_msg, ": ") else ""
    stop(context_part, guidance, " (API error ", error_code, ")", call. = FALSE)
    
  } else {
    # Fallback for non-standard error responses
    context_part <- if (nchar(context_msg) > 0) paste0(context_msg, ": ") else ""
    stop(context_part, "Unexpected API response format.", call. = FALSE)
  }
}

#' Handle network/connection errors with retry suggestions
#'
#' @param error The original error
#' @param context_msg Additional context for the error
#' @return Stops execution with informative error message
handle_network_error <- function(error, context_msg = "") {
  context_part <- if (nchar(context_msg) > 0) paste0(context_msg, ": ") else ""
  
  if (grepl("timeout|connection|network", error$message, ignore.case = TRUE)) {
    stop(context_part, "Network connection failed. Check your internet connection and try again. ",
         "For intermittent failures, consider implementing retry logic.", call. = FALSE)
  } else {
    stop(context_part, error$message, call. = FALSE)
  }
}

#' Warn about deprecated functionality with migration guidance
#'
#' @param old_function Name of deprecated function
#' @param new_function Name of replacement function
#' @param version Version when deprecation will become an error
warn_deprecated <- function(old_function, new_function, version = "next major version") {
  warning("Function '", old_function, "' is deprecated and will be removed in ", version, ". ",
          "Please use '", new_function, "' instead.", 
          call. = FALSE, immediate. = TRUE)
}

#' Provide helpful suggestions for common user errors
#'
#' @param issue_type Type of issue encountered
#' @param details Additional details for the suggestion
suggest_solution <- function(issue_type, details = "") {
  
  suggestions <- list(
    auth_token = paste0(
      "Authentication required. Run yt_oauth() to set up OAuth2 authentication, ",
      "or use yt_set_key() for API key authentication."
    ),
    quota_limit = paste0(
      "Approaching quota limits. Check usage with yt_get_quota_usage() and consider:\n",
      "- Using API keys for read-only operations (more efficient)\n",
      "- Implementing request delays with Sys.sleep()\n",
      "- Caching results to reduce repeated calls"
    ),
    rate_limit = paste0(
      "Rate limited by YouTube API. Consider:\n",
      "- Adding delays between requests with Sys.sleep(0.1)\n", 
      "- Using smaller batch sizes for bulk operations\n",
      "- Implementing exponential backoff retry logic"
    ),
    empty_results = paste0(
      "No results found. This could be due to:\n",
      "- Incorrect ID or search parameters\n",
      "- Content being private or deleted\n", 
      "- Regional restrictions\n",
      details
    )
  )
  
  if (issue_type %in% names(suggestions)) {
    message("💡 Suggestion: ", suggestions[[issue_type]])
  }
}

#' Exponential backoff retry logic for API calls
#' 
#' Implements exponential backoff with jitter for retrying failed API calls
#'
#' @param expr Expression to evaluate (usually an API call)
#' @param max_retries Maximum number of retry attempts
#' @param base_delay Base delay in seconds for first retry
#' @param max_delay Maximum delay in seconds
#' @param backoff_factor Multiplier for delay between retries
#' @param jitter Whether to add random jitter to prevent thundering herd
#' @param retry_on Function that takes an error and returns TRUE if should retry
#' @param on_retry Function called on each retry attempt with attempt number and error
#' @return Result of successful expression evaluation
#' @export
with_retry <- function(expr, 
                       max_retries = 3, 
                       base_delay = 1, 
                       max_delay = 60,
                       backoff_factor = 2,
                       jitter = TRUE,
                       retry_on = function(e) is_transient_error(e),
                       on_retry = NULL) {
  
  attempt <- 1
  last_error <- NULL
  
  repeat {
    result <- tryCatch({
      # Execute the expression
      eval(expr, envir = parent.frame())
    }, error = function(e) {
      last_error <<- e
      e  # Return the error
    })
    
    # If successful, return result
    if (!inherits(result, "error")) {
      return(result)
    }
    
    # If we've reached max retries or error is not transient, give up
    if (attempt > max_retries || !retry_on(result)) {
      # Call the original error with context
      if (attempt > 1) {
        stop("Failed after ", attempt - 1, " retry attempts. Last error: ", result$message, call. = FALSE)
      } else {
        stop(result$message, call. = FALSE)
      }
    }
    
    # Calculate delay with exponential backoff and optional jitter
    delay <- min(base_delay * (backoff_factor ^ (attempt - 1)), max_delay)
    if (jitter) {
      delay <- delay * (0.5 + 0.5 * runif(1))  # Add 0-50% jitter
    }
    
    # Call retry callback if provided
    if (!is.null(on_retry)) {
      on_retry(attempt, result)
    } else {
      message("Retry attempt ", attempt, "/", max_retries, " in ", round(delay, 2), " seconds...")
    }
    
    # Wait before retry
    Sys.sleep(delay)
    attempt <- attempt + 1
  }
}

#' Check if an error is transient and worth retrying
#' 
#' @param error Error object to check
#' @return Logical indicating if error is transient
is_transient_error <- function(error) {
  error_msg <- tolower(error$message)
  
  # Network/connection errors
  if (grepl("timeout|connection reset|network|socket|dns", error_msg)) {
    return(TRUE)
  }
  
  # HTTP 5xx server errors (but not 4xx client errors)
  if (grepl("internal server error|bad gateway|service unavailable|gateway timeout", error_msg)) {
    return(TRUE)
  }
  
  # Rate limiting (429)
  if (grepl("rate limit|too many requests|429", error_msg)) {
    return(TRUE)
  }
  
  # Specific YouTube API temporary errors
  if (grepl("backend error|service error|temporarily unavailable", error_msg)) {
    return(TRUE)
  }
  
  # SSL/TLS handshake issues
  if (grepl("ssl|tls|certificate", error_msg)) {
    return(TRUE)
  }
  
  return(FALSE)
}

#' Wrapper for tuber API calls with built-in retry logic
#' 
#' @param api_function The tuber API function to call
#' @param ... Arguments to pass to the API function
#' @param retry_config List of retry configuration options
#' @return Result of API function call
call_api_with_retry <- function(api_function, ..., retry_config = list()) {
  
  # Default retry configuration
  default_config <- list(
    max_retries = 3,
    base_delay = 1,
    max_delay = 30,
    backoff_factor = 2,
    jitter = TRUE
  )
  
  # Merge user config with defaults
  config <- modifyList(default_config, retry_config)
  
  # Custom retry callback for API calls
  api_on_retry <- function(attempt, error) {
    if (grepl("rate limit|429", tolower(error$message))) {
      message("Rate limited. Retrying attempt ", attempt, " after delay...")
    } else if (grepl("quota", tolower(error$message))) {
      message("Quota issues detected. Retrying attempt ", attempt, "...")
    } else {
      message("Transient error detected. Retrying attempt ", attempt, "/", config$max_retries, "...")
    }
  }
  
  with_retry(
    api_function(...),
    max_retries = config$max_retries,
    base_delay = config$base_delay,
    max_delay = config$max_delay,
    backoff_factor = config$backoff_factor,
    jitter = config$jitter,
    on_retry = api_on_retry
  )
}

#' Validate YouTube-specific IDs and parameters
#'
#' Specialized validation functions for YouTube API parameters

#' Validate YouTube video ID format
#'
#' @param video_id Video ID to validate
#' @param name Parameter name for error messages
#' @return Invisible NULL if valid, stops execution if invalid
validate_video_id <- function(video_id, name = "video_id") {
  validate_character(video_id, name)
  
  # YouTube video IDs are typically 11 characters long
  if (any(nchar(video_id) != 11)) {
    stop("Parameter '", name, "' must be valid YouTube video ID(s) (11 characters).", call. = FALSE)
  }
  
  # Basic pattern check (alphanumeric, hyphens, underscores)
  if (any(!grepl("^[A-Za-z0-9_-]+$", video_id))) {
    stop("Parameter '", name, "' contains invalid characters for YouTube video ID.", call. = FALSE)
  }
  
  invisible(NULL)
}

#' Validate YouTube channel ID format
#'
#' @param channel_id Channel ID to validate
#' @param name Parameter name for error messages
#' @return Invisible NULL if valid, stops execution if invalid
validate_channel_id <- function(channel_id, name = "channel_id") {
  validate_character(channel_id, name)
  
  # YouTube channel IDs start with "UC" and are 24 characters total
  if (any(!grepl("^UC[A-Za-z0-9_-]{22}$", channel_id))) {
    stop("Parameter '", name, "' must be valid YouTube channel ID(s) starting with 'UC'.", call. = FALSE)
  }
  
  invisible(NULL)
}

#' Validate YouTube playlist ID format
#'
#' @param playlist_id Playlist ID to validate
#' @param name Parameter name for error messages
#' @return Invisible NULL if valid, stops execution if invalid
validate_playlist_id <- function(playlist_id, name = "playlist_id") {
  validate_character(playlist_id, name)
  
  # YouTube playlist IDs typically start with "PL" or "UU" and are 34 characters total
  if (any(!grepl("^(PL|UU|FL|LL)[A-Za-z0-9_-]{32}$", playlist_id))) {
    stop("Parameter '", name, "' must be valid YouTube playlist ID(s).", call. = FALSE)
  }
  
  invisible(NULL)
}

#' Validate RFC 3339 date format for YouTube API
#'
#' @param date_string Date string to validate
#' @param name Parameter name for error messages
#' @return Invisible NULL if valid, stops execution if invalid
validate_rfc3339_date <- function(date_string, name) {
  validate_character(date_string, name)
  
  # RFC 3339 format: YYYY-MM-DDTHH:MM:SSZ or YYYY-MM-DDTHH:MM:SS+HH:MM
  rfc3339_pattern <- "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(Z|[+-]\\d{2}:\\d{2})$"
  
  if (any(!grepl(rfc3339_pattern, date_string))) {
    stop("Parameter '", name, "' must be in RFC 3339 format (e.g., '2023-01-01T00:00:00Z').", call. = FALSE)
  }
  
  # Try to parse the date to ensure it's valid
  tryCatch({
    as.POSIXct(date_string, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  }, error = function(e) {
    stop("Parameter '", name, "' contains an invalid date: ", date_string, call. = FALSE)
  })
  
  invisible(NULL)
}

#' Validate YouTube API part parameters
#'
#' @param part Part parameter value(s)
#' @param endpoint API endpoint name for context-specific validation
#' @param name Parameter name for error messages
#' @return Invisible NULL if valid, stops execution if invalid
validate_part_parameter <- function(part, endpoint, name = "part") {
  validate_character(part, name)
  
  # Define valid parts for each endpoint
  valid_parts <- list(
    videos = c("contentDetails", "fileDetails", "id", "liveStreamingDetails", 
               "localizations", "player", "processingDetails", "recordingDetails",
               "snippet", "statistics", "status", "suggestions", "topicDetails"),
    channels = c("auditDetails", "brandingSettings", "contentDetails", "contentOwnerDetails",
                 "id", "localizations", "snippet", "statistics", "status", "topicDetails"),
    playlists = c("contentDetails", "id", "localizations", "player", "snippet", "status"),
    playlistItems = c("contentDetails", "id", "snippet", "status"),
    search = c("snippet"),
    comments = c("id", "snippet"),
    commentThreads = c("id", "replies", "snippet"),
    activities = c("contentDetails", "id", "snippet"),
    subscriptions = c("contentDetails", "id", "snippet", "subscriberSnippet"),
    captions = c("id", "snippet"),
    liveBroadcasts = c("contentDetails", "id", "snippet", "statistics", "status"),
    channelSections = c("contentDetails", "id", "localizations", "snippet", "targeting"),
    videoCategories = c("snippet"),
    i18nLanguages = c("snippet"),
    i18nRegions = c("snippet")
  )
  
  if (endpoint %in% names(valid_parts)) {
    # Split comma-separated parts
    parts <- trimws(strsplit(part, ",")[[1]])
    invalid_parts <- setdiff(parts, valid_parts[[endpoint]])
    
    if (length(invalid_parts) > 0) {
      stop("Parameter '", name, "' contains invalid parts for ", endpoint, " endpoint: ", 
           paste(invalid_parts, collapse = ", "), 
           ". Valid parts are: ", paste(valid_parts[[endpoint]], collapse = ", "), ".", 
           call. = FALSE)
    }
  }
  
  invisible(NULL)
}

#' Validate region codes
#'
#' @param region_code Region code to validate (ISO 3166-1 alpha-2)
#' @param name Parameter name for error messages
#' @return Invisible NULL if valid, stops execution if invalid
validate_region_code <- function(region_code, name = "region_code") {
  validate_character(region_code, name)
  
  # ISO 3166-1 alpha-2 codes are exactly 2 uppercase letters
  if (any(nchar(region_code) != 2 || !grepl("^[A-Z]{2}$", region_code))) {
    stop("Parameter '", name, "' must be a valid ISO 3166-1 alpha-2 region code (e.g., 'US', 'GB').", 
         call. = FALSE)
  }
  
  invisible(NULL)
}

#' Validate language codes
#'
#' @param language_code Language code to validate (ISO 639-1 or BCP-47)
#' @param name Parameter name for error messages
#' @return Invisible NULL if valid, stops execution if invalid
validate_language_code <- function(language_code, name = "language_code") {
  validate_character(language_code, name)
  
  # Accept ISO 639-1 (2 letters) or BCP-47 format (e.g., en-US)
  if (any(!grepl("^[a-z]{2}(-[A-Z]{2})?$", language_code))) {
    stop("Parameter '", name, "' must be a valid language code (e.g., 'en', 'en-US').", 
         call. = FALSE)
  }
  
  invisible(NULL)
}

#' Comprehensive parameter validation for YouTube API functions
#'
#' @param params List of parameters to validate
#' @param endpoint API endpoint for context-specific validation
#' @return Invisible NULL if all valid, stops execution if any invalid
validate_youtube_params <- function(params, endpoint = NULL) {
  
  for (param_name in names(params)) {
    param_value <- params[[param_name]]
    
    if (is.null(param_value)) next  # Skip NULL parameters
    
    # Apply appropriate validation based on parameter name
    switch(param_name,
      video_id = validate_video_id(param_value, param_name),
      videoId = validate_video_id(param_value, "video_id"),
      channel_id = validate_channel_id(param_value, param_name),
      channelId = validate_channel_id(param_value, "channel_id"),
      playlist_id = validate_playlist_id(param_value, param_name),
      playlistId = validate_playlist_id(param_value, "playlist_id"),
      part = if(!is.null(endpoint)) validate_part_parameter(param_value, endpoint, param_name),
      region_code = validate_region_code(param_value, param_name),
      regionCode = validate_region_code(param_value, "region_code"),
      hl = validate_language_code(param_value, "language_code"),
      published_after = validate_rfc3339_date(param_value, param_name),
      publishedAfter = validate_rfc3339_date(param_value, "published_after"),
      published_before = validate_rfc3339_date(param_value, param_name),
      publishedBefore = validate_rfc3339_date(param_value, "published_before"),
      max_results = validate_numeric(param_value, param_name, min = 1, max = 50, integer_only = TRUE),
      maxResults = validate_numeric(param_value, "max_results", min = 1, max = 50, integer_only = TRUE),
      # Default: basic validation for other parameters
      if (is.character(param_value)) validate_character(param_value, param_name)
    )
  }
  
  invisible(NULL)
}