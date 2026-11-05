#' @title \pkg{tuber} provides access to the YouTube API V3.
#'
#' @description \pkg{tuber} provides access to the YouTube API V3 via
#' RESTful calls.
#'
#' @name tuber
#' @importFrom askpass askpass
#' @importFrom checkmate assert_character assert_numeric assert_integerish
#' @importFrom checkmate assert_logical assert_choice assert_string assert_list
#' @importFrom checkmate assert_flag assert_count
#' @importFrom rlang abort warn inform %||%
#' @importFrom httr2 request req_url_path_append req_url_query req_headers
#' @importFrom httr2 req_headers_redacted req_body_json req_body_raw req_body_file
#' @importFrom httr2 req_method
#' @importFrom httr2 req_error req_user_agent req_perform resp_body_json resp_body_string
#' @importFrom httr2 resp_body_raw resp_has_body resp_header
#' @importFrom httr2 oauth_client oauth_flow_auth_code oauth_flow_refresh
#' @importFrom httr2 resp_status
#' @importFrom utils modifyList head object.size
#' @importFrom stats median quantile runif
#' @importFrom digest digest
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom dplyr bind_rows group_by summarise n arrange desc rename
#' @importFrom tibble enframe
#' @importFrom tidyselect all_of
#' @importFrom tidyr pivot_wider unnest unnest_wider
NULL
#' @keywords internal
"_PACKAGE"

#' Add standardized metadata attributes to API response
#'
#' Adds consistent metadata attributes to function return values for better
#' debugging and quota management.
#'
#' @param result The result object to add attributes to
#' @param api_calls_made Number of API calls made to generate this result
#' @param quota_used Estimated quota units consumed by the operation. If
#' `NULL`, no quota attribute is added.
#' @param function_name Name of the calling function
#' @param parameters List of key parameters used in the function call
#' @param timestamp When the API call was made
#' @param ... Additional custom attributes
#'
#' @return The result object with standardized attributes added
#' @keywords internal
add_tuber_attributes <- function(result,
                                 api_calls_made = 1,
                                 quota_used = NULL,
                                 function_name = NULL,
                                 parameters = list(),
                                 timestamp = Sys.time(),
                                 ...) {
  # Standard attributes
  attr(result, "tuber_api_calls") <- api_calls_made
  if (!is.null(quota_used)) {
    attr(result, "tuber_quota_used") <- quota_used
  }
  attr(result, "tuber_timestamp") <- timestamp
  attr(result, "tuber_function") <- function_name %||% deparse(sys.call(-1)[[1]])
  attr(result, "tuber_parameters") <- parameters

  # Add any custom attributes
  extra_attrs <- list(...)
  for (name in names(extra_attrs)) {
    attr(result, paste0("tuber_", name)) <- extra_attrs[[name]]
  }

  # Add class for potential S3 methods
  if (!inherits(result, "tuber_result")) {
    class(result) <- unique(c("tuber_result", class(result)))
  }

  result
}

#' Paginate API requests with standardized pattern
#'
#' Helper function to handle pagination for YouTube API requests consistently.
#' Collects items across multiple pages until max_results or max_pages is reached.
#'
#' Every page after the first is asked for no more items than are still
#' wanted. Asking for a full page and trimming it would leave
#' \code{final_page_token} pointing past items that were never returned, so a
#' caller resuming from that token would silently skip them.
#'
#' @param initial_response The response from the initial API call
#' @param fetch_next_page_fn Function that takes a page token and the number of
#' items still wanted, and returns the next page
#' @param extract_items_fn Function to extract items from a response. Default: function(res)
#' res$items
#' @param max_results Maximum number of items to collect. Default: Inf
#' @param max_pages Maximum number of pages to retrieve. Default: Inf
#' @return List with items (all collected items) and metadata
#' @keywords internal
paginate_api_request <- function(initial_response,
                                 fetch_next_page_fn,
                                 extract_items_fn = function(res) res$items,
                                 max_results = Inf,
                                 max_pages = Inf) {
  all_items <- extract_items_fn(initial_response)
  if (length(all_items) > max_results) {
    all_items <- all_items[seq_len(max_results)]
  }
  page_token <- initial_response$nextPageToken
  page_count <- 1

  while (!is.null(page_token) && is.character(page_token) &&
           length(all_items) < max_results && page_count < max_pages) {
    remaining <- max_results - length(all_items)
    next_response <- fetch_next_page_fn(page_token, remaining)
    new_items <- extract_items_fn(next_response)
    page_token <- next_response$nextPageToken
    page_count <- page_count + 1

    if (is.null(new_items) || length(new_items) == 0) {
      break
    }

    if (length(new_items) > remaining) {
      new_items <- new_items[seq_len(remaining)]
    }

    all_items <- c(all_items, new_items)
  }

  list(
    items = all_items,
    page_count = page_count,
    has_more = !is.null(page_token) && is.character(page_token),
    final_page_token = page_token
  )
}

#' Build a request against the YouTube Data API
#'
#' One place where the base URL, credentials, user agent and error policy are
#' set, so every verb below differs only in method and body.
#'
#' @param path API endpoint path (e.g., "videos", "channels")
#' @param query Named list of query parameters
#' @param auth Either \code{"token"} for OAuth or \code{"key"} for an API key
#' @param prefix Path prefix. Media uploads live under \code{upload/youtube/v3}
#'   rather than \code{youtube/v3}.
#' @return An httr2 request object ready for method-specific modifications
#' @keywords internal
tuber_request <- function(path, query = list(), auth = "token",
                          prefix = "youtube/v3") {
  req <- request("https://www.googleapis.com") |>
    req_url_path_append(prefix, path)

  if (length(query) > 0) {
    req <- req_url_query(req, !!!query)
  }

  req <- if (auth == "token") {
    req_headers_redacted(req, Authorization = paste("Bearer", yt_access_token()))
  } else {
    yt_check_key()
    req_headers_redacted(req, "x-goog-api-key" = suppressMessages(yt_get_key()))
  }

  # YouTube puts the useful part of a failure in the response body, and
  # tuber_check() translates it. httr2's own abort would discard it.
  req |>
    req_error(is_error = function(response) FALSE) |>
    req_user_agent("tuber (https://github.com/gojiplus/tuber)")
}

#' Perform a request and check the response
#'
#' @param req An httr2 request
#' @return An httr2 response
#' @keywords internal
tuber_perform <- function(req) {
  resp <- req_perform(req)
  handle_http_response(resp)
  tuber_check(resp)
  resp
}

#' Parse a JSON response body, tolerating an empty one
#'
#' A 204 carries no body, and resp_body_json() errors rather than returning
#' nothing.
#'
#' @param resp An httr2 response
#' @return A list, or NULL when the response has no body
#' @keywords internal
tuber_json <- function(resp) {
  if (!resp_has_body(resp)) {
    return(NULL)
  }
  resp_body_json(resp)
}

#' Display tuber function metadata
#'
#' Shows the metadata attributes added to tuber function results for debugging
#' and quota management.
#'
#' @param result A result object from a tuber function with metadata attributes
#' @return `result`, invisibly, after printing its metadata; `NULL`, invisibly,
#' when `result` carries none.
#' @export
#'
#' @examples
#' \dontrun{
#' result <- get_video_details("dQw4w9WgXcQ")
#' tuber_info(result)
#' }
tuber_info <- function(result) {
  if (!inherits(result, "tuber_result")) {
    message("This object doesn't have tuber metadata attributes.")
    return(invisible(NULL))
  }

  cat("Tuber Function Metadata\n")
  cat("=======================\n")

  attrs <- attributes(result)
  tuber_attrs <- attrs[grep("^tuber_", names(attrs))]

  for (name in names(tuber_attrs)) {
    clean_name <- sub("^tuber_", "", name)
    value <- tuber_attrs[[name]]

    # Format different types appropriately
    formatted_value <- if (inherits(value, "POSIXct")) {
      format(value, "%Y-%m-%d %H:%M:%S %Z")
    } else if (is.list(value) && length(value) > 0) {
      paste(names(value), "=", value, collapse = ", ")
    } else if (is.list(value)) {
      "{empty list}"
    } else {
      as.character(value)
    }

    cat(sprintf("%-15s: %s\n", clean_name, formatted_value))
  }

  invisible(result)
}

#' Print method for tuber results
#'
#' Custom print method that shows key metadata alongside the result data
#'
#' @param x A tuber_result object
#' @param ... Additional arguments passed to default print methods
#' @export
#' @keywords internal
print.tuber_result <- function(x, ...) {
  # Print the main content first (removing tuber_result class temporarily)
  content_classes <- class(x)[class(x) != "tuber_result"]
  class(x) <- content_classes
  print(x, ...)

  # Show metadata summary
  attrs <- attributes(x)
  tuber_attrs <- attrs[grep("^tuber_", names(attrs))]

  if (length(tuber_attrs) > 0) {
    cat("\n--- Tuber Metadata ---\n")

    # Show most important attributes
    key_attrs <- c("tuber_function", "tuber_api_calls", "tuber_results_found", "tuber_timestamp")

    for (attr_name in key_attrs) {
      if (attr_name %in% names(tuber_attrs)) {
        value <- tuber_attrs[[attr_name]]
        clean_name <- sub("^tuber_", "", attr_name)

        formatted_value <- if (inherits(value, "POSIXct")) {
          format(value, "%Y-%m-%d %H:%M:%S")
        } else {
          as.character(value)
        }

        cat(sprintf("%s: %s  ", clean_name, formatted_value))
      }
    }

    cat("\n(Use tuber_info() for full metadata)\n")
  }

  # Restore the original class
  class(x) <- c("tuber_result", content_classes)
  invisible(x)
}

#' Subset method for tuber results
#'
#' Preserves tuber metadata attributes when subsetting
#'
#' @param x A tuber_result object
#' @param ... Arguments passed to the underlying subset method
#' @export
#' @keywords internal
`[.tuber_result` <- function(x, ...) {
  result <- NextMethod("[")

  # Preserve tuber attributes
  attrs <- attributes(x)
  tuber_attrs <- attrs[grep("^tuber_", names(attrs))]
  for (name in names(tuber_attrs)) {
    attr(result, name) <- tuber_attrs[[name]]
  }

  class(result) <- unique(c("tuber_result", class(result)))
  result
}

#' Summary method for tuber results
#'
#' Displays a summary of the tuber API result including metadata
#'
#' @param object A tuber_result object
#' @param ... Additional arguments (ignored)
#' @export
#' @keywords internal
summary.tuber_result <- function(object, ...) {
  cat("Tuber API Result\n")
  cat("================\n")

  if (is.data.frame(object)) {
    cat("Rows:", nrow(object), "\n")
    cat("Columns:", ncol(object), "\n")
    if (ncol(object) > 0) {
      cat("Column names:", paste(head(names(object), 5), collapse = ", "))
      if (ncol(object) > 5) cat(" ...")
      cat("\n")
    }
  } else if (is.list(object)) {
    cat("Type: list\n")
    cat("Elements:", length(object), "\n")
  }

  cat("\n")
  cat("API calls:", attr(object, "tuber_api_calls") %||% "unknown", "\n")
  cat("Results found:", attr(object, "tuber_results_found") %||% "unknown", "\n")
  cat("Function:", attr(object, "tuber_function") %||% "unknown", "\n")

  timestamp <- attr(object, "tuber_timestamp")
  if (!is.null(timestamp)) {
    cat("Timestamp:", format(timestamp, "%Y-%m-%d %H:%M:%S"), "\n")
  }

  invisible(object)
}

#' Check if authentication token is in options
#' @return `yt_token()` returns the httr2 token set by [yt_oauth()], or `NULL`
#' when there is none. `yt_authorized()` returns `TRUE` when a token is set.
#' @export
#' @examples
#' yt_authorized()
yt_token <- function() {
  getOption("google_token")
}

#' @export
#' @rdname yt_token
yt_authorized <- function() {
  !is.null(yt_token())
}

#' @rdname yt_token
yt_check_token <- function() {
  if (!yt_authorized()) {
    abort("Please get a token using yt_oauth().", class = "tuber_auth_required")
  }
}

#' Manage YouTube API key
#'
#' @name yt_key
#' @aliases yt_get_key yt_set_key
#' @export yt_get_key yt_set_key
#'
#' @description
#' These functions read and set the YouTube API key in the current R process.
#' @usage
#' yt_get_key()
#' yt_set_key(key)
#'
#' @param key A character vector specifying a YouTube API key.
#'
#' @return
#' `yt_get_key()` returns `YOUTUBE_KEY` invisibly, or `NULL` when it is unset.
#'
#' `yt_set_key()` sets `YOUTUBE_KEY` for the current R process and invisibly
#' returns the key. Put the variable in a user-level `.Renviron` file yourself
#' if it must persist across sessions. In continuous integration, supply it
#' from the service's secret store as an environment variable.
#'
#' @examples
#' \dontrun{
#' yt_set_key("YOUR_YOUTUBE_API_KEY")
#' yt_get_key()
#'
#' list_channel_videos(
#'   channel_id = "UCDgj5-mFohWZ5irWSFMFcng",
#'   max_results = 3,
#'   auth = "key"
#' )
#' }
yt_get_key <- function() {
  api_key <- Sys.getenv("YOUTUBE_KEY")
  if (identical(api_key, "")) {
    message("No YOUTUBE_KEY environment variable found")
    if (!interactive() || !isTRUE(utils::askYesNo("Do you want to set YOUTUBE_KEY?"))) {
      return(invisible(NULL))
    }
    api_key <- yt_set_key()
  }
  invisible(api_key)
}

yt_set_key <- function(key = NULL) {
  if (is.null(key) && interactive()) {
    key <- askpass("Please enter your YouTube API key")
  }
  if (is.null(key)) {
    return(invisible(NULL))
  }
  assert_character(key, len = 1, min.chars = 1, .var.name = "key")
  Sys.setenv(YOUTUBE_KEY = key)
  message("YOUTUBE_KEY was set for the current R process and invisibly returned")
  invisible(key)
}

yt_authorized_key <- function() {
  !is.null(suppressMessages(yt_get_key()))
}

yt_check_key <- function() {
  if (!yt_authorized_key()) {
    abort("Please set a YouTube API key using `yt_set_key()`.", class = "tuber_key_required")
  }
}

#'
#' GET
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param auth A character vector of the authentication method, either "token" (the default) or
#' "key"
#' @return list
#' @keywords internal

tuber_GET <- function(path, query, auth = "token") { # nolint: object_name_linter.
  assert_character(path, len = 1, min.chars = 1, .var.name = "path")
  assert_list(query, .var.name = "query")
  assert_choice(auth, c("token", "key"), .var.name = "auth")

  cache_key <- NULL
  if (auth == "key" && is_cacheable_endpoint(path)) {
    cache_key <- generate_cache_key(path, query)
    cached_response <- get_cached_response(cache_key)
    if (!is.null(cached_response)) {
      attr(cached_response, "tuber_cache_hit") <- TRUE
      return(cached_response)
    }
  }

  method <- if (grepl("^captions/", path)) "download" else "list"
  track_quota_usage(path, method)

  resp <- tuber_perform(tuber_request(path, query, auth))

  res <- if (grepl("^captions/", path)) {
    if (resp_has_body(resp)) resp_body_raw(resp) else raw(0)
  } else {
    tuber_json(resp)
  }

  if (!is.null(cache_key)) {
    store_cached_response(cache_key, res)
  }

  res
}

#' Open a resumable media upload session
#'
#' YouTube's resumable protocol is two requests: a metadata POST that returns a
#' session URL in the Location header, then a PUT of the bytes to that URL.
#' This is the first half.
#'
#' @param path API endpoint path under \code{upload/youtube/v3}
#' @param query query list
#' @param metadata list serialized as the JSON metadata body
#' @param file path to the file that will be uploaded
#' @param type MIME type of \code{file}
#' @return The session URL as a string
#' @keywords internal
tuber_upload_session <- function(path, query, metadata, file, type) {
  resp <- tuber_request(path, query = query, prefix = "upload/youtube/v3") |>
    req_method("POST") |>
    req_headers(
      "X-Upload-Content-Length" = as.character(file.size(file)),
      "X-Upload-Content-Type" = type
    ) |>
    req_body_raw(
      toJSON(metadata, auto_unbox = TRUE, null = "null"),
      type = "application/json; charset=UTF-8"
    ) |>
    req_perform()

  if (resp_status(resp) < 200 || resp_status(resp) >= 300) {
    tuber_check(resp)
    abort(
      "Failed to initiate resumable upload",
      status_code = resp_status(resp),
      class = "tuber_upload_init_failed"
    )
  }

  upload_url <- resp_header(resp, "location")
  if (is.null(upload_url) || !nzchar(upload_url)) {
    abort(
      "YouTube did not return a resumable upload URL.",
      class = "tuber_upload_location_missing"
    )
  }
  upload_url
}

#'
#' Write request with a JSON body
#'
#' @param path path to specific API request URL
#' @param method HTTP method, one of "POST", "PUT" or "DELETE"
#' @param query query list
#' @param body list serialized as the JSON request body
#' @param quota_method quota category recorded for this call
#' @return An httr2 response
#' @keywords internal

tuber_write <- function(path, method, query, body = NULL, quota_method) {
  assert_character(path, len = 1, min.chars = 1, .var.name = "path")
  assert_list(query, .var.name = "query")
  yt_check_token()
  track_quota_usage(path, quota_method)

  req <- req_method(tuber_request(path, query, auth = "token"), method)
  if (!is.null(body) && !identical(body, "")) {
    req <- req_body_json(req, body)
  }
  tuber_perform(req)
}

#'
#' POST encoded in json
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param body list serialized as the JSON request body
#'
#' @return list
#' @keywords internal

tuber_POST_json <- function(path, query, body = "") { # nolint: object_name_linter.
  tuber_json(tuber_write(path, "POST", query, body, "insert"))
}

#'
#' PUT
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param body list serialized as the JSON request body
#' @return list
#' @keywords internal

tuber_PUT <- function(path, query, body = "") { # nolint: object_name_linter.
  tuber_json(tuber_write(path, "PUT", query, body, "update"))
}

#'
#' DELETE
#'
#' @param path path to specific API request URL
#' @param query query list
#' @return list
#' @keywords internal

tuber_DELETE <- function(path, query) { # nolint: object_name_linter.
  resp <- tuber_write(path, "DELETE", query, NULL, "delete")
  invisible(if (resp_has_body(resp)) resp_body_raw(resp) else raw(0))
}

#'
#' Warn when YouTube is rate limiting
#'
#' A 429 is reported as a warning before [tuber_check()] turns the response
#' into an error, so the advice is visible even when the error is retried.
#'
#' @param req The HTTP response object
#' @return NULL invisibly if no errors, otherwise stops with informative message
#' @keywords internal
handle_http_response <- function(req) {
  status <- resp_status(req)

  if (is.null(status) || status < 400) {
    return(invisible(NULL))
  }

  if (status == 429) {
    warn("Rate limited by YouTube API. Consider adding delays between requests.",
      class = "tuber_rate_limited"
    )
  }

  invisible(NULL)
}

#' Request Response Verification
#'
#' @param  req request
#' @return in case of failure, a message
#' @keywords internal

tuber_check <- function(req) {
  status <- resp_status(req)
  if (status < 400) return(invisible(NULL))

  # Google's standard error body is {"error": {"message", "errors": [{"reason"}]}},
  # but OAuth failures, proxies and gateways send other shapes, so nothing
  # about the structure is assumed.
  body <- tryCatch(resp_body_string(req), error = function(e) "")
  parsed <- tryCatch(fromJSON(body, simplifyVector = FALSE), error = function(e) NULL)
  error <- if (is.list(parsed) && is.list(parsed$error)) parsed$error else list()

  msg <- error$message
  if (!is.character(msg) || length(msg) != 1) msg <- body
  first_error <- if (is.list(error$errors) && length(error$errors) > 0) {
    error$errors[[1]]
  }
  reason <- if (is.list(first_error) && is.character(first_error$reason)) {
    first_error$reason
  } else {
    NA_character_
  }

  if (status == 403 && reason %in% c("quotaExceeded", "dailyLimitExceeded")) {
    abort(
      "YouTube API quota exhausted. Check project usage in Google Cloud Console.",
      class = c("tuber_quota_exhausted", "tuber_http_error"),
      status_code = status,
      reason = reason,
      quota_status = yt_get_quota_usage()
    )
  }

  # Enhanced error handling for common 403 issues
  if (status == 403) {
    # The reason code is authoritative. The wording is only consulted when
    # there is no code, because "disabled" also appears in unrelated errors
    # such as commentsDisabled.
    api_disabled <- if (is.na(reason)) {
      grepl("has not been used|is disabled", msg, ignore.case = TRUE)
    } else {
      reason == "accessNotConfigured"
    }
    if (api_disabled) {
      enhanced_msg <- paste0(
        "YouTube Data API is not enabled for your project.\n\n",
        "SOLUTION:\n",
        "1. Go to Google Cloud Console: https://console.cloud.google.com/\n",
        "2. Select your project (or create a new one)\n",
        "3. Enable the YouTube Data API v3:\n",
        "   https://developers.google.com/youtube/v3/getting-started\n",
        "4. Wait 2-5 minutes for the API to be fully activated\n",
        "5. Try your request again\n\n",
        "Original error: ", msg
      )
      abort(paste0("HTTP failure: ", status, "\n", enhanced_msg),
        class = "tuber_api_not_enabled",
        status_code = status,
        reason = reason
      )
    }
  }

  abort(paste0("HTTP failure: ", status, "\n", msg),
    class = "tuber_http_error",
    status_code = status,
    reason = reason
  )
}
