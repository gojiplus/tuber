#' Tuber Error Handling Utilities
#'
#' Standardized error handling functions for consistent error messages
#' and recovery strategies across the tuber package.
#'
#' @name error-handling
#' @keywords internal
NULL

#' Provide helpful suggestions for common user errors
#'
#' @param issue_type Type of issue encountered
#' @param details Additional details for the suggestion
#' @keywords internal
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
    message("Suggestion: ", suggestions[[issue_type]])
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
#' @keywords internal
with_retry <- function(expr,
                       max_retries = 3,
                       base_delay = 1,
                       max_delay = 60,
                       backoff_factor = 2,
                       jitter = TRUE,
                       retry_on = function(e) is_transient_error(e),
                       on_retry = NULL) {
  expr <- substitute(expr)
  eval_env <- parent.frame()
  attempt <- 1

  repeat {
    result <- tryCatch(
      {
        # Execute the expression
        eval(expr, envir = eval_env)
      },
      error = function(e) {
        e # Return the error
      }
    )

    # If successful, return result
    if (!inherits(result, "error")) {
      return(result)
    }

    # If we've reached max retries or error is not transient, give up
    if (attempt > max_retries || !retry_on(result)) {
      result$retry_attempts <- attempt - 1L
      stop(result)
    }

    # Calculate delay with exponential backoff and optional jitter
    delay <- min(base_delay * (backoff_factor^(attempt - 1)), max_delay)
    if (jitter) {
      delay <- delay * (0.5 + 0.5 * runif(1))
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

#' Was this request refused for lack of permission?
#'
#' A 403 that is not quota exhaustion, which is also a 403 but has nothing to
#' do with what the account may access.
#'
#' @param error A condition
#' @return Logical
#' @keywords internal
#' @noRd
is_refused <- function(error) {
  inherits(error, "tuber_http_error") &&
    !inherits(error, "tuber_quota_exhausted") &&
    isTRUE(error$status_code == 403)
}

#' Check if an error is transient and worth retrying
#'
#' @param error Error object to check
#' @return Logical indicating if error is transient
#' @keywords internal
is_transient_error <- function(error) {
  status <- error$status_code %||%
    error$response$status_code %||%
    attr(error, "status_code", exact = TRUE)
  if (!is.null(status) && length(status) == 1 && !is.na(status)) {
    return(status %in% c(408L, 429L) || (status >= 500L && status <= 599L))
  }

  if (inherits(error, "httr2_failure")) {
    return(TRUE)
  }

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

  FALSE
}

#' Wrapper for tuber API calls with built-in retry logic
#'
#' @param api_function The tuber API function to call
#' @param ... Arguments to pass to the API function
#' @param retry_config List of retry configuration options
#' @return Result of API function call
#' @keywords internal
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
      message(
        "Transient error detected. Retrying attempt ",
        attempt, "/", config$max_retries, "..."
      )
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

#' Validate RFC 3339 date format for YouTube API
#'
#' @param date_string Date string to validate
#' @param name Parameter name for error messages
#' @param call The frame to report in the error: the function the user called.
#' @return Invisible NULL if valid, stops execution if invalid
#' @keywords internal
validate_rfc3339_date <- function(date_string, name, call = rlang::caller_env()) {
  assert_character(date_string, len = 1, min.chars = 1, .var.name = name)

  rfc3339_pattern <- paste0(
    "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?",
    "(Z|[+-]\\d{2}:\\d{2})$"
  )
  # Parsed as UTC whatever the offset says: the point is to reject
  # impossible fields such as month 13, and a local time zone would also
  # reject real instants that fall in its daylight-saving gap.
  parsed <- as.POSIXct(
    substr(date_string, 1, 19),
    format = "%Y-%m-%dT%H:%M:%S",
    tz = "UTC"
  )

  if (!grepl(rfc3339_pattern, date_string) || is.na(parsed)) {
    abort(
      c(
        paste0("`", name, "` is not a valid RFC 3339 date-time: \"", date_string, "\"."),
        i = "Use YYYY-MM-DDTHH:MM:SSZ or YYYY-MM-DDTHH:MM:SS+HH:MM, e.g. 2023-01-01T00:00:00Z."
      ),
      parameter = name,
      date_string = date_string,
      class = "tuber_invalid_date_format",
      call = call
    )
  }

  invisible(NULL)
}
