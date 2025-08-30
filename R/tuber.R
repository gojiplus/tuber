#' @title \pkg{tuber} provides access to the YouTube API V3.
#'
#' @description \pkg{tuber} provides access to the YouTube API V3 via
#' RESTful calls.
#'
#' @name tuber
#' @importFrom askpass askpass
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
NULL
#' @keywords internal
"_PACKAGE"


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

tuber_GET <- function(path, query, auth = "token", ...) {
  # Track quota usage
  parts <- query$part %||% NULL
  track_quota_usage(path, parts)

  if (auth == "token") {
    yt_check_token()
    req <- GET("https://www.googleapis.com", path = paste0("youtube/v3/", path),
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
      req_user_agent("tuber (https://github.com/soodoku/tuber)") %>%
      req_perform()
    res <- req %>% resp_body_json()
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
      req_user_agent("tuber (https://github.com/soodoku/tuber)") %>%
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
      req_user_agent("tuber (https://github.com/soodoku/tuber)") %>%
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
      req_user_agent("tuber (https://github.com/soodoku/tuber)") %>%
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
  msg <- paste0(msg, "\n")
  stop("HTTP failure: ", req$status_code, "\n", msg, call. = FALSE)
}
