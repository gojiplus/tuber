#' @title \pkg{tuber} provides access to the YouTube API V3.
#'
#' @description \pkg{tuber} provides access to the YouTube API V3 via
#' RESTful calls.
#'
#' @name tuber
#' @importFrom askpass askpass
#' @importFrom checkmate assert_character assert_numeric assert_integerish
#' @importFrom checkmate assert_logical assert_choice assert_string assert_list
#' @importFrom rlang abort warn inform is_missing %||%
#' @importFrom httr GET POST PUT DELETE authenticate config stop_for_status
#' @importFrom httr upload_file content oauth_endpoints oauth_app oauth2.0_token
#' @importFrom httr2 request req_url_path_append req_url_query req_headers
#' @importFrom httr2 req_user_agent req_perform resp_body_json req_body_json
#' @importFrom httr2 req_method resp_body_string req_body_raw secret_encrypt secret_decrypt
#' @importFrom utils read.table modifyList head object.size
#' @importFrom stats median quantile
#' @importFrom digest digest
#' @importFrom plyr ldply rbind.fill
#' @importFrom dplyr bind_rows select pull filter mutate
#' @importFrom tibble enframe
#' @importFrom tidyselect everything all_of
#' @importFrom tidyr pivot_wider unnest unnest_longer
#' @importFrom purrr map_df map_dbl flatten
#' @importFrom R6 R6Class
NULL
#' @keywords internal
"_PACKAGE"

#' Null coalescing operator
#'
#' Returns the right-hand side if the left-hand side is NULL or has length 0.
#'
#' @param x Left-hand side value
#' @param y Right-hand side value (default if x is NULL/empty)
#' @return x if x is not NULL and has length > 0, otherwise y
#' @export
#' @name null-coalesce
#' @rdname null-coalesce
#' @examples
#' \dontrun{
#' NULL %||% "default"  # Returns "default"
#' "value" %||% "default"  # Returns "value"
#' character(0) %||% "default"  # Returns "default"
#' }
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}

#' Add standardized metadata attributes to API response
#'
#' Adds consistent metadata attributes to function return values for better
#' debugging and quota management.
#'
#' @param result The result object to add attributes to
#' @param api_calls_made Number of API calls made to generate this result
#' @param quota_used Estimated quota units consumed
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
  
  # Get current quota status if not provided
  if (is.null(quota_used)) {
    quota_status <- yt_get_quota_usage()
    quota_used <- quota_status$quota_used
  }
  
  # Standard attributes
  attr(result, "tuber_api_calls") <- api_calls_made
  attr(result, "tuber_quota_used") <- quota_used
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
    class(result) <- c("tuber_result", class(result))
  }
  
  return(result)
}

#' Display tuber function metadata
#'
#' Shows the metadata attributes added to tuber function results for debugging
#' and quota management.
#'
#' @param result A result object from a tuber function with metadata attributes
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


#' Check if authentication token is in options
#' @return A Token2.0 class
#' @export
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
    stop("Please get a token using yt_oauth().\n")
  }

}

#' Manage YouTube API key
#'
#' @name yt_key
#' @aliases yt_get_key yt_set_key
#' @export yt_get_key yt_set_key
#'
#' @description
#' These functions manage your YouTube API key and package key in \code{.Renviron}.
#' @usage
#' yt_get_key(decrypt = FALSE)
#' yt_set_key(key, type)
#'
#' @param decrypt A boolean vector specifying whether to decrypt the supplied key with `httr2::secret_decrypt()`. Defaults to `FALSE`. If `TRUE`, requires the environment variable `TUBER_KEY` to be set in `.Renviron`.
#' @param key A character vector specifying a YouTube API key.
#' @param type A character vector specifying the type of API key to set. One of 'api' (the default, stored in `YOUTUBE_KEY`) or 'package'. Package keys are stored in `TUBER_KEY` and are used to decrypt API keys, for use in continuous integration and testing.
#'
#' @return
#' `yt_get_key()` returns a character vector with the YouTube API key stored in `.Renviron`. If this value is not stored in `.Renviron`, the functions return `NULL`.
#'
#' When the `type` argument is set to 'api', `yt_set_key()` assigns a YouTube API key to `YOUTUBE_KEY` in `.Renviron` and invisibly returns `NULL`. When the `type` argument is set to 'package', `yt_set_key()` assigns a package key to `TUBER_KEY` in `.Renviron` and invisibly returns `NULL`.
#'
#' @examples
#' \dontrun{
#' ## for interactive use
#' yt_get_key()
#'
#' list_channel_videos(
#'   channel_id = "UCDgj5-mFohWZ5irWSFMFcng",
#'   max_results = 3,
#'   part = "snippet",
#'   auth = "key"
#' )
#'
#' ## for continuous integration and testing
#' yt_set_key(httr2::secret_make_key(), type = "package")
#' x <- httr2::secret_encrypt("YOUR_YOUTUBE_API_KEY", "TUBER_KEY")
#' yt_set_key(x, type = "api")
#' yt_get_key(decrypt = TRUE)
#'
#' list_channel_videos(
#'   channel_id = "UCDgj5-mFohWZ5irWSFMFcng",
#'   max_results = 3,
#'   part = "snippet",
#'   auth = "key"
#' )
#' }

yt_get_key <- function(decrypt = FALSE) {
  api_key <- Sys.getenv("YOUTUBE_KEY")
  pkg_key <- Sys.getenv("TUBER_KEY")
  if (identical(api_key, "")) {
    message("No YOUTUBE_KEY environment variable found")
    if (interactive()) {
      answer <- utils::askYesNo("Do you want to set YOUTUBE_KEY?")
      if (isTRUE(answer)) {
        api_key <- yt_set_key()
        if (is.null(api_key)) {
          return(invisible(NULL))
        }
      }
    } else {
      return(invisible(NULL))
    }
  }
  if (!identical(api_key, "")) {
    if (decrypt && !identical(pkg_key, "")) {
      api_key <- secret_decrypt(api_key, "TUBER_KEY")
      message("YOUTUBE_KEY was decrypted with TUBER_KEY and was invisibly returned")
    }
    if (decrypt && identical(pkg_key, "")) {
      stop(
        "Decryption requires a package key.\n",
        "Please set a package key using `yt_set_key(type = 'package')`.",
        call. = FALSE
      )
    }
    invisible(api_key)
  }
}

yt_set_key <- function(key = NULL, type = "api") {
  if (type == "api") {
    if (interactive() && is.null(key)) {
      key <- askpass("Please enter your YouTube API key")
      if (is.null(key) || !is.character(key)) {
        return(invisible(NULL))
      }
    } else if (is.null(key)) {
      return(invisible(NULL))
    }
    stopifnot("YOUTUBE_KEY must be a character vector" = is.character(key))
    Sys.setenv(YOUTUBE_KEY = key)
    message("YOUTUBE_KEY was stored in '.Renviron' and was invisibly returned")
  }
  if (type == "package") {
    if (interactive() && is.null(key)) {
      key <- askpass("Please enter your package key")
      if (is.null(key) || !is.character(key)) {
        return(invisible(NULL))
      }
    } else if (is.null(key)) {
      return(invisible(NULL))
    }
    stopifnot("TUBER_KEY must be a character vector" = is.character(key))
    Sys.setenv(TUBER_KEY = key)
    message("TUBER_KEY was stored in '.Renviron' and was invisibly returned")
  }
  invisible(key)
}

yt_authorized_key <- function() {
  !is.null(suppressMessages(yt_get_key()))
}

yt_check_key <- function() {
  if (!yt_authorized_key()) {
    stop("Please set a YouTube API key using `yt_set_key()`.\n")
  }
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

#'
#' GET
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param auth A character vector of the authentication method, either "token" (the default) or "key"
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}}.
#' @return list

tuber_GET <- function(path, query, auth = "token", use_etag = TRUE, ...) {
  # Modern validation using checkmate
  assert_character(path, len = 1, min.chars = 1, .var.name = "path")
  assert_list(query, .var.name = "query")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_flag(use_etag, .var.name = "use_etag")
  
  # Track quota usage
  parts <- query$part %||% NULL
  track_quota_usage(path, parts)
  
  # Generate cache key for ETag support
  cache_key <- NULL
  if (use_etag && tuber_config_get("api.enable_etags", TRUE)) {
    cache_key <- generate_cache_key(path, query, auth)
    
    # Check for cached ETag
    cached_etag <- get_cached_etag(cache_key)
    if (!is.null(cached_etag)) {
      query$etag <- cached_etag
    }
  }

  if (auth == "token") {
    yt_check_token()
    
    # Add ETag header support
    headers <- list()
    if (!is.null(query$etag)) {
      headers[["If-None-Match"]] <- query$etag
      query$etag <- NULL  # Remove from query params
    }
    
    req <- GET("https://www.googleapis.com", 
               path = paste0("youtube/v3/", path),
               query = query, 
               config(token = getOption("google_token")),
               httr::add_headers(.headers = headers), 
               ...)
    
    # Handle 304 Not Modified
    if (status_code(req) == 304) {
      cached_response <- get_cached_response(cache_key)
      if (!is.null(cached_response)) {
        return(cached_response)
      }
    }
    
    res <- content(req)
    
    # Cache new ETag and response
    if (use_etag && !is.null(cache_key) && status_code(req) == 200) {
      response_etag <- headers(req)[["etag"]]
      if (!is.null(response_etag)) {
        cache_etag_and_response(cache_key, response_etag, res)
      }
    }
  }

  if (auth == "key") {
    yt_check_key()
    
    req_builder <- request("https://www.googleapis.com") %>%
      req_url_path_append("youtube/v3", path) %>%
      req_url_query(!!!query) %>%
      req_headers("x-goog-api-key" = suppressMessages(yt_get_key())) %>%
      req_user_agent("tuber (https://github.com/gojiplus/tuber)")
    
    # Add ETag header support for httr2
    if (!is.null(query$etag)) {
      req_builder <- req_builder %>% req_headers("If-None-Match" = query$etag)
    }
    
    req <- req_builder %>% req_perform()
    
    # Handle 304 Not Modified
    if (resp_status(req) == 304) {
      cached_response <- get_cached_response(cache_key)
      if (!is.null(cached_response)) {
        return(cached_response)
      }
    }
    
    res <- req %>% resp_body_json()
    
    # Cache new ETag and response
    if (use_etag && !is.null(cache_key) && resp_status(req) == 200) {
      response_etag <- resp_headers(req)[["etag"]]
      if (!is.null(response_etag)) {
        cache_etag_and_response(cache_key, response_etag, res)
      }
    }
  }

  # Check for rate limiting and quota errors
  if (exists("req") && !is.null(req$status_code)) {
    if (req$status_code == 403) {
      # Check if it's a quota error
      error_content <- tryCatch({
        if (auth == "token") content(req, as = "text") else httr2::resp_body_string(req)
      }, error = function(e) "")
      
      if (grepl("quotaExceeded|dailyLimitExceeded", error_content)) {
        quota_status <- yt_get_quota_usage()
        stop("YouTube API quota exhausted. Used: ", quota_status$quota_used, "/", quota_status$quota_limit, 
             ". Quota resets at: ", format(quota_status$reset_time, "%Y-%m-%d %H:%M:%S UTC"))
      }
    }
    
    if (req$status_code == 429) {
      warning("Rate limited by YouTube API. Consider adding delays between requests.")
    }
  }

  tuber_check(req)

  res
}

#'
#' POST
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param body passing image through body
#' @param auth A character vector of the authentication method, either "token" (the default) or "key"
#' @param \dots Additional arguments passed to \code{\link[httr]{POST}}.
#'
#' @return list

tuber_POST <- function(path, query, body = "", auth = "token", ...) {
  # Track quota usage
  parts <- query$part %||% NULL
  track_quota_usage(path, parts)

  if (auth == "token") {
    yt_check_token()
    req <- POST("https://www.googleapis.com", path = paste0("youtube/v3/", path),
                body = body, query = query,
                config(token = getOption("google_token")), ...)
    res <- content(req)
  }

  if (auth == "key") {
    yt_check_key()
    req <-
      request("https://www.googleapis.com") %>%
      req_url_path_append("youtube/v3", path) %>%
      req_url_query(!!!query) %>%
      req_headers("x-goog-api-key" = suppressMessages(yt_get_key())) %>%
      req_user_agent("tuber (https://github.com/gojiplus/tuber)") %>%
      req_body_raw(body) %>%
      req_perform()
    res <- req %>% resp_body_json()
  }

  # Check for rate limiting and quota errors (same as tuber_GET)
  if (exists("req") && !is.null(req$status_code)) {
    if (req$status_code == 403) {
      error_content <- tryCatch({
        if (auth == "token") content(req, as = "text") else httr2::resp_body_string(req)
      }, error = function(e) "")
      
      if (grepl("quotaExceeded|dailyLimitExceeded", error_content)) {
        quota_status <- yt_get_quota_usage()
        stop("YouTube API quota exhausted. Used: ", quota_status$quota_used, "/", quota_status$quota_limit, 
             ". Quota resets at: ", format(quota_status$reset_time, "%Y-%m-%d %H:%M:%S UTC"))
      }
    }
    
    if (req$status_code == 429) {
      warning("Rate limited by YouTube API. Consider adding delays between requests.")
    }
  }

  tuber_check(req)
  res
}

#'
#' POST encoded in json
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param body passing image through body
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}}.
#'
#' @return list

tuber_POST_json <- function(path, query, body = "", ...) {

  yt_check_token()

  req <- httr::POST("https://www.googleapis.com", path = paste0("youtube/v3/", path),
                    body = body, query = query,
                    config(token = getOption("google_token")),
                    encode = "json", ...)

  tuber_check(req)
  res <- content(req)

  res
}

#'
#' PUT
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param body JSON body content for the PUT request
#' @param auth A character vector of the authentication method, either "token" (the default) or "key"
#' @param \dots Additional arguments passed to \code{\link[httr]{PUT}}.
#' @return list

tuber_PUT <- function(path, query, body = "", auth = "token", ...) {
  # Track quota usage
  parts <- query$part %||% NULL
  track_quota_usage(path, parts)

  if (auth == "token") {
    yt_check_token()
    req <- PUT("https://www.googleapis.com", path = paste0("youtube/v3/", path),
               query = query, config(token = getOption("google_token")),
               body = body, encode = "json", ...)
    res <- content(req)
  }

  if (auth == "key") {
    yt_check_key()
    req <- 
      request("https://www.googleapis.com") %>%
      req_url_path_append("youtube/v3", path) %>%
      req_url_query(!!!query) %>%
      req_headers("x-goog-api-key" = suppressMessages(yt_get_key())) %>%
      req_user_agent("tuber (https://github.com/gojiplus/tuber)") %>%
      req_body_json(body) %>%
      req_perform()
    res <- req %>% resp_body_json()
  }

  # Check for rate limiting and quota errors (same as tuber_GET)
  if (exists("req") && !is.null(req$status_code)) {
    if (req$status_code == 403) {
      error_content <- tryCatch({
        if (auth == "token") content(req, as = "text") else httr2::resp_body_string(req)
      }, error = function(e) "")
      
      if (grepl("quotaExceeded|dailyLimitExceeded", error_content)) {
        quota_status <- yt_get_quota_usage()
        stop("YouTube API quota exhausted. Used: ", quota_status$quota_used, "/", quota_status$quota_limit, 
             ". Quota resets at: ", format(quota_status$reset_time, "%Y-%m-%d %H:%M:%S UTC"))
      }
    }
    
    if (req$status_code == 429) {
      warning("Rate limited by YouTube API. Consider adding delays between requests.")
    }
  }

  tuber_check(req)
  
  res
}

#'
#' DELETE
#'
#' @param path path to specific API request URL
#' @param query query list
#' @param auth A character vector of the authentication method, either "token" (the default) or "key"
#' @param \dots Additional arguments passed to \code{\link[httr]{DELETE}}.
#' @return list

tuber_DELETE <- function(path, query, auth = "token", ...) {
  # Track quota usage
  parts <- query$part %||% NULL
  track_quota_usage(path, parts)

  if (auth == "token") {
    yt_check_token()
    req <- DELETE("https://www.googleapis.com", path = paste0("youtube/v3/", path),
                  query = query, config(token = getOption("google_token")), ...)
    res <- content(req)
  }

  if (auth == "key") {
    yt_check_key()
    req <-
      request("https://www.googleapis.com") %>%
      req_url_path_append("youtube/v3", path) %>%
      req_url_query(!!!query) %>%
      req_headers("x-goog-api-key" = suppressMessages(yt_get_key())) %>%
      req_user_agent("tuber (https://github.com/gojiplus/tuber)") %>%
      req_method("DELETE") %>%
      req_perform()
    res <- req %>% resp_body_json()
  }

  # Check for rate limiting and quota errors (same as tuber_GET)
  if (exists("req") && !is.null(req$status_code)) {
    if (req$status_code == 403) {
      error_content <- tryCatch({
        if (auth == "token") content(req, as = "text") else httr2::resp_body_string(req)
      }, error = function(e) "")
      
      if (grepl("quotaExceeded|dailyLimitExceeded", error_content)) {
        quota_status <- yt_get_quota_usage()
        stop("YouTube API quota exhausted. Used: ", quota_status$quota_used, "/", quota_status$quota_limit, 
             ". Quota resets at: ", format(quota_status$reset_time, "%Y-%m-%d %H:%M:%S UTC"))
      }
    }
    
    if (req$status_code == 429) {
      warning("Rate limited by YouTube API. Consider adding delays between requests.")
    }
  }

  tuber_check(req)
  res
}

#'
#' Request Response Verification
#'
#' @param  req request
#' @return in case of failure, a message

tuber_check <- function(req) {

  if (req$status_code < 400) return(invisible(NULL))
  orig_out <-  httr::content(req, as = "text")
  out <- try({
    jsonlite::fromJSON(
      orig_out,
      flatten = TRUE)
  }, silent = TRUE)
  if (inherits(out, "try-error")) {
    msg <- orig_out
  } else {
    msg <- out$error$message
  }
  
  # Enhanced error handling for common 403 issues
  if (req$status_code == 403) {
    if (grepl("accessNotConfigured|has not been used|is disabled", msg, ignore.case = TRUE)) {
      enhanced_msg <- paste0(
        "YouTube Data API is not enabled for your project.\n\n",
        "SOLUTION:\n",
        "1. Go to Google Cloud Console: https://console.cloud.google.com/\n",
        "2. Select your project (or create a new one)\n",
        "3. Enable the YouTube Data API v3:\n",
        "   https://console.cloud.google.com/marketplace/product/google/youtube.googleapis.com\n",
        "4. Wait 2-5 minutes for the API to be fully activated\n",
        "5. Try your request again\n\n",
        "Original error: ", msg, "\n"
      )
      stop("HTTP failure: ", req$status_code, "\n", enhanced_msg, call. = FALSE)
    }
  }
  
  msg <- paste0(msg, "\n")
  stop("HTTP failure: ", req$status_code, "\n", msg, call. = FALSE)
}
