#' YouTube API Quota Management
#'
#' Functions to track and manage YouTube API quota usage
#' @name quota_management
NULL

# Session-local quota estimates. Google is the source of truth for project
# usage; these counters help users understand calls made by this R session.
.tuber_env <- new.env(parent = emptyenv())

next_quota_reset <- function(now = Sys.time()) {
  quota_tz <- "America/Los_Angeles"
  today <- as.Date(format(now, tz = quota_tz))
  as.POSIXct(paste(today + 1, "00:00:00"), tz = quota_tz)
}

initialize_quota_state <- function() {
  .tuber_env$quota_used <- c(data = 0L, search = 0L, video_uploads = 0L)
  .tuber_env$quota_limit <- c(data = 10000L, search = 100L, video_uploads = 100L)
  .tuber_env$quota_reset_time <- next_quota_reset()
  .tuber_env$request_times <- numeric()
}

initialize_quota_state()

#' Get Current Quota Usage
#'
#' Returns session-local estimated quota usage for the current quota day.
#' Actual project usage is available in the Google Cloud Console.
#'
#' @return A data frame with one row per quota bucket and columns for estimated
#' usage, configured limits, remaining quota, and reset time.
#' @export
#'
#' @examples
#' \dontrun{
#' quota_status <- yt_get_quota_usage()
#' quota_status[quota_status$bucket == "data", ]
#' }
yt_get_quota_usage <- function() {
  if (Sys.time() > .tuber_env$quota_reset_time) {
    yt_reset_quota()
  }

  data.frame(
    bucket = names(.tuber_env$quota_used),
    quota_used = unname(.tuber_env$quota_used),
    quota_limit = unname(.tuber_env$quota_limit),
    quota_remaining = pmax(0, .tuber_env$quota_limit - .tuber_env$quota_used),
    reset_time = rep(.tuber_env$quota_reset_time, length(.tuber_env$quota_used)),
    requests_last_minute = rep(
      sum(.tuber_env$request_times > as.numeric(Sys.time() - 60)),
      length(.tuber_env$quota_used)
    ),
    row.names = NULL
  )
}

#' Set Quota Limit
#'
#' Set the daily quota limit (default is 10,000 units)
#'
#' @param limit Integer. Daily quota limit for the selected bucket.
#' @param bucket Quota bucket: `"data"`, `"search"`, or `"video_uploads"`.
#' @export
#'
#' @examples
#' \dontrun{
#' # If you have a higher quota limit
#' yt_set_quota_limit(50000, bucket = "data")
#' }
yt_set_quota_limit <- function(limit, bucket = "data") {
  assert_count(limit, positive = TRUE, .var.name = "limit")
  assert_choice(bucket, names(.tuber_env$quota_limit), .var.name = "bucket")
  .tuber_env$quota_limit[[bucket]] <- as.integer(limit)
  invisible(.tuber_env$quota_limit[[bucket]])
}

#' Reset Quota Counter
#'
#' Reset the quota counter (typically done automatically at midnight Pacific
#' Time, when YouTube's daily quota resets)
#'
#' @export
yt_reset_quota <- function() {
  .tuber_env$quota_used[] <- 0L
  .tuber_env$quota_reset_time <- next_quota_reset()
  .tuber_env$request_times <- numeric()
  invisible(NULL)
}

#' Track Quota Usage
#'
#' Internal function to track API usage
#'
#' @param endpoint Character. API resource name.
#' @param method Character. API method such as `"list"`, `"insert"`,
#' `"update"`, `"delete"`, or `"download"`.
#'
#' @keywords internal
quota_cost <- function(endpoint, method) {
  endpoint <- sub("/.*$", "", endpoint)
  key <- paste(endpoint, method, sep = ".")

  if (identical(key, "search.list")) {
    return(list(bucket = "search", cost = 1L))
  }
  if (identical(key, "videos.insert")) {
    return(list(bucket = "video_uploads", cost = 1L))
  }

  costs <- c(
    "captions.list" = 50L,
    "captions.download" = 200L,
    "captions.insert" = 400L,
    "captions.update" = 450L,
    "members.list" = 2L,
    "thumbnails.set" = 50L
  )

  default_cost <- switch(method,
    list = 1L,
    get = 1L,
    insert = 50L,
    update = 50L,
    delete = 50L,
    set = 50L,
    1L
  )

  specific_cost <- unname(costs[key])
  if (is.na(specific_cost)) specific_cost <- default_cost

  list(bucket = "data", cost = specific_cost)
}

track_quota_usage <- function(endpoint, method = "list") {
  assert_character(endpoint, len = 1, min.chars = 1, .var.name = "endpoint")
  assert_choice(
    method,
    c("list", "get", "insert", "update", "delete", "download", "set"),
    .var.name = "method"
  )

  if (Sys.time() > .tuber_env$quota_reset_time) {
    yt_reset_quota()
  }

  estimate <- quota_cost(endpoint, method)
  .tuber_env$quota_used[[estimate$bucket]] <-
    .tuber_env$quota_used[[estimate$bucket]] + estimate$cost
  .tuber_env$request_times <- c(.tuber_env$request_times, as.numeric(Sys.time()))

  one_hour_ago <- as.numeric(Sys.time() - 3600)
  .tuber_env$request_times <- .tuber_env$request_times[.tuber_env$request_times > one_hour_ago]

  quota_status <- yt_get_quota_usage()
  bucket_status <- quota_status[quota_status$bucket == estimate$bucket, , drop = FALSE]

  if (bucket_status$quota_remaining <= 0) {
    warn("Estimated YouTube API quota limit reached for this session",
      bucket = estimate$bucket,
      quota_used = bucket_status$quota_used,
      quota_limit = bucket_status$quota_limit,
      reset_time = bucket_status$reset_time,
      class = "tuber_quota_exceeded"
    )
  } else if (bucket_status$quota_remaining <= max(1, 0.01 * bucket_status$quota_limit)) {
    warn("Estimated YouTube API quota nearly exhausted for this session",
      bucket = estimate$bucket,
      quota_remaining = bucket_status$quota_remaining,
      class = "tuber_quota_warning"
    )
  }

  if (bucket_status$requests_last_minute > 50) {
    inform("High request rate detected",
      requests_last_minute = bucket_status$requests_last_minute,
      help = "Consider adding delays between API calls",
      class = "tuber_high_request_rate"
    )
  }

  invisible(estimate)
}

#' Add Exponential Backoff
#'
#' Internal function to handle rate limiting with exponential backoff
#'
#' @param attempt_number Integer. Current attempt number
#' @param max_attempts Integer. Maximum attempts before giving up
#' @param base_delay Numeric. Base delay in seconds
#'
#' @importFrom stats runif
#' @keywords internal
exponential_backoff <- function(attempt_number, max_attempts = 5, base_delay = 1) {
  # Modern validation using checkmate
  assert_integerish(attempt_number, len = 1, lower = 1, .var.name = "attempt_number")
  assert_integerish(max_attempts, len = 1, lower = 1, .var.name = "max_attempts")
  assert_numeric(base_delay, len = 1, lower = 0, .var.name = "base_delay")

  if (attempt_number > max_attempts) {
    abort("Maximum retry attempts exceeded",
      attempt_number = attempt_number,
      max_attempts = max_attempts,
      class = "tuber_max_retries_exceeded"
    )
  }

  if (attempt_number > 1) {
    delay <- base_delay * (2^(attempt_number - 2)) # 1, 2, 4, 8 seconds...
    delay <- delay + runif(1, 0, 0.5)
    message("Rate limited. Waiting ", round(delay, 2), " seconds before retry...")
    Sys.sleep(delay)
  }
}
