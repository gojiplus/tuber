#' Response Caching for YouTube API
#'
#' Implements intelligent caching for static YouTube API data to reduce quota usage
#' and improve performance. Particularly useful for video categories, regions,
#' languages, and other data that changes infrequently.
#'
#' @name caching
NULL

# Global environment for cache storage
.tuber_cache <- new.env(parent = emptyenv())

#' Configure caching settings
#'
#' @param enabled Whether to enable caching globally
#' @param default_ttl Default time-to-live in seconds
#' @param max_size Maximum number of cached items
#' @param cache_dir Directory for persistent cache (NULL for memory only)
#' @export
tuber_cache_config <- function(enabled = TRUE,
                              default_ttl = 3600,  # 1 hour
                              max_size = 1000,
                              cache_dir = NULL) {

  # Modern validation using checkmate
  assert_flag(enabled, .var.name = "enabled")
  assert_integerish(default_ttl, len = 1, lower = 60, upper = 86400, .var.name = "default_ttl")
  assert_integerish(max_size, len = 1, lower = 10, upper = 10000, .var.name = "max_size")

  if (!is.null(cache_dir)) {
    assert_character(cache_dir, len = 1, min.chars = 1, .var.name = "cache_dir")
  }

  .tuber_cache$config <- list(
    enabled = enabled,
    default_ttl = default_ttl,
    max_size = max_size,
    cache_dir = cache_dir,
    created_at = Sys.time()
  )

  if (!is.null(cache_dir) && !dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
    message("Created cache directory: ", cache_dir)
  }

  message("Tuber caching configured: enabled=", enabled, ", TTL=", default_ttl, "s")
  invisible(NULL)
}

#' Get current cache configuration
#'
#' @return List with cache configuration
#' @export
tuber_cache_info <- function() {
  config <- .tuber_cache$config %||% list(enabled = FALSE)

  # Add runtime stats
  config$items_cached <- length(ls(.tuber_cache, pattern = "^cache_"))
  config$memory_usage <- format(object.size(.tuber_cache), units = "MB")

  return(config)
}

#' Clear cache entries
#'
#' @param pattern Regular expression pattern to match cache keys (NULL for all)
#' @param older_than Clear entries older than this many seconds
#' @export
tuber_cache_clear <- function(pattern = NULL, older_than = NULL) {

  # Modern validation using checkmate
  if (!is.null(pattern)) {
    assert_character(pattern, len = 1, .var.name = "pattern")
  }

  if (!is.null(older_than)) {
    assert_integerish(older_than, len = 1, lower = 0, .var.name = "older_than")
  }

  cache_keys <- ls(.tuber_cache, pattern = "^cache_")

  if (!is.null(pattern)) {
    cache_keys <- cache_keys[grepl(pattern, cache_keys)]
  }

  cleared_count <- 0

  for (key in cache_keys) {
    should_clear <- TRUE

    if (!is.null(older_than)) {
      cache_entry <- get(key, envir = .tuber_cache)
      age <- as.numeric(difftime(Sys.time(), cache_entry$created_at, units = "secs"))
      should_clear <- age > older_than
    }

    if (should_clear) {
      rm(list = key, envir = .tuber_cache)
      cleared_count <- cleared_count + 1
    }
  }

  message("Cleared ", cleared_count, " cache entries")
  invisible(cleared_count)
}

#' Generate cache key for API call
#'
#' @param endpoint API endpoint name
#' @param query Query parameters
#' @param auth Authentication method
#' @return Character cache key
generate_cache_key <- function(endpoint, query, auth) {
  # Sort query parameters for consistent keys
  query_sorted <- query[sort(names(query))]
  query_str <- paste(names(query_sorted), query_sorted, sep = "=", collapse = "&")

  key_parts <- c(endpoint, auth, query_str)
  cache_key <- paste0("cache_", digest::digest(key_parts, algo = "md5"))

  return(cache_key)
}

#' Check if endpoint should be cached
#'
#' @param endpoint API endpoint name
#' @return Logical indicating if endpoint is cacheable
is_cacheable_endpoint <- function(endpoint) {
  # Static data endpoints that change infrequently
  static_endpoints <- c(
    "videoCategories",
    "i18nLanguages",
    "i18nRegions",
    "guidecategories",
    # Channel info (changes rarely)
    "channels",
    # Video details for specific fields that don't change
    "videos"  # Only for certain parts like snippet, recordingDetails
  )

  return(endpoint %in% static_endpoints)
}

#' Check if query parameters indicate static data
#'
#' @param endpoint API endpoint
#' @param query Query parameters
#' @return Logical indicating if this specific query is cacheable
is_static_query <- function(endpoint, query) {

  # Video categories - always static
  if (endpoint == "videoCategories") return(TRUE)

  # Languages and regions - always static
  if (endpoint %in% c("i18nLanguages", "i18nRegions")) return(TRUE)

  # Guide categories - always static
  if (endpoint == "guidecategories") return(TRUE)

  # Channels - cache basic info but not analytics
  if (endpoint == "channels") {
    parts <- strsplit(query$part %||% "", ",")[[1]]
    # Cache basic info, not analytics or dynamic content
    static_parts <- c("snippet", "brandingSettings", "contentDetails", "topicDetails")
    return(all(parts %in% static_parts))
  }

  # Videos - only cache certain parts
  if (endpoint == "videos") {
    parts <- strsplit(query$part %||% "", ",")[[1]]
    # Cache immutable video metadata, not view counts or comments
    static_parts <- c("snippet", "recordingDetails", "topicDetails", "contentDetails")
    return(all(parts %in% static_parts))
  }

  return(FALSE)
}

#' Get cached response if available and valid
#'
#' @param cache_key Cache key
#' @return Cached response or NULL if not available/expired
get_cached_response <- function(cache_key) {

  config <- .tuber_cache$config %||% list(enabled = FALSE)
  if (!config$enabled) return(NULL)

  if (!exists(cache_key, envir = .tuber_cache)) return(NULL)

  cache_entry <- get(cache_key, envir = .tuber_cache)

  # Check if expired
  age <- as.numeric(difftime(Sys.time(), cache_entry$created_at, units = "secs"))
  if (age > cache_entry$ttl) {
    rm(list = cache_key, envir = .tuber_cache)
    return(NULL)
  }

  return(cache_entry$data)
}

#' Store response in cache
#'
#' @param cache_key Cache key
#' @param data Response data to cache
#' @param ttl Time-to-live in seconds (NULL for default)
store_cached_response <- function(cache_key, data, ttl = NULL) {

  config <- .tuber_cache$config %||% list(enabled = FALSE)
  if (!config$enabled) return(invisible(NULL))

  # Use default TTL if not specified
  if (is.null(ttl)) {
    ttl <- config$default_ttl %||% 3600
  }

  # Check cache size limits
  current_size <- length(ls(.tuber_cache, pattern = "^cache_"))
  max_size <- config$max_size %||% 1000

  if (current_size >= max_size) {
    # Remove oldest entries
    cache_keys <- ls(.tuber_cache, pattern = "^cache_")
    oldest_keys <- head(cache_keys, current_size - max_size + 1)
    rm(list = oldest_keys, envir = .tuber_cache)
  }

  # Store cache entry
  cache_entry <- list(
    data = data,
    created_at = Sys.time(),
    ttl = ttl
  )

  assign(cache_key, cache_entry, envir = .tuber_cache)
  invisible(NULL)
}

#' Cached version of tuber_GET with automatic caching
#'
#' @param path API endpoint path
#' @param query Query parameters
#' @param auth Authentication method
#' @param cache_ttl Override default TTL for this call
#' @param force_refresh Skip cache and force fresh API call
#' @param ... Additional arguments passed to tuber_GET
#' @return API response (from cache or fresh call)
#' @export
tuber_GET_cached <- function(path, query, auth = "token",
                            cache_ttl = NULL, force_refresh = FALSE, ...) {

  # Modern validation using checkmate
  assert_character(path, len = 1, min.chars = 1, .var.name = "path")
  assert_list(query, .var.name = "query")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_flag(force_refresh, .var.name = "force_refresh")

  if (!is.null(cache_ttl)) {
    assert_integerish(cache_ttl, len = 1, lower = 60, .var.name = "cache_ttl")
  }

  # Check if this endpoint/query should be cached
  if (!force_refresh && is_cacheable_endpoint(path) && is_static_query(path, query)) {

    cache_key <- generate_cache_key(path, query, auth)

    # Try to get from cache first
    cached_response <- get_cached_response(cache_key)
    if (!is.null(cached_response)) {
      return(cached_response)
    }

    # Cache miss - make API call
    response <- tuber_GET(path, query, auth, ...)

    # Store in cache for future use
    store_cached_response(cache_key, response, cache_ttl)

    return(response)

  } else {
    # Not cacheable or force refresh - make direct API call
    return(tuber_GET(path, query, auth, ...))
  }
}

#' Enhanced versions of static data functions with caching
#'
#' These functions automatically cache responses to reduce API quota usage
#' for data that changes infrequently.

#' List video categories with caching
#'
#' @param region_code Region code for categories
#' @param auth Authentication method
#' @param cache_ttl Cache time-to-live (default: 24 hours for categories)
#' @param ... Additional arguments
#' @return Video categories data
#' @export
list_videocats_cached <- function(region_code = "US", auth = "key", cache_ttl = 86400, ...) {

  # Modern validation using checkmate
  assert_character(region_code, len = 1, pattern = "^[A-Z]{2}$", .var.name = "region_code")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_integerish(cache_ttl, len = 1, lower = 60, .var.name = "cache_ttl")

  query <- list(part = "snippet", regionCode = region_code)

  result <- tuber_GET_cached("videoCategories", query, auth, cache_ttl = cache_ttl, ...)

  return(result)
}

#' List supported languages with caching
#'
#' @param auth Authentication method
#' @param cache_ttl Cache time-to-live (default: 24 hours)
#' @param ... Additional arguments
#' @return Languages data
#' @export
list_langs_cached <- function(auth = "key", cache_ttl = 86400, ...) {

  # Modern validation using checkmate
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_integerish(cache_ttl, len = 1, lower = 60, .var.name = "cache_ttl")

  query <- list(part = "snippet")

  result <- tuber_GET_cached("i18nLanguages", query, auth, cache_ttl = cache_ttl, ...)

  return(result)
}

#' List supported regions with caching
#'
#' @param auth Authentication method
#' @param cache_ttl Cache time-to-live (default: 24 hours)
#' @param ... Additional arguments
#' @return Regions data
#' @export
list_regions_cached <- function(auth = "key", cache_ttl = 86400, ...) {

  # Modern validation using checkmate
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_integerish(cache_ttl, len = 1, lower = 60, .var.name = "cache_ttl")

  query <- list(part = "snippet")

  result <- tuber_GET_cached("i18nRegions", query, auth, cache_ttl = cache_ttl, ...)

  return(result)
}

#' Get channel information with caching (for static parts)
#'
#' @param channel_id Channel ID
#' @param part Parts to retrieve (only static parts will be cached)
#' @param auth Authentication method
#' @param cache_ttl Cache time-to-live (default: 1 hour for channel info)
#' @param ... Additional arguments
#' @return Channel information
#' @export
get_channel_info_cached <- function(channel_id, part = "snippet,brandingSettings",
                                   auth = "key", cache_ttl = 3600, ...) {

  # Modern validation using checkmate
  assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
  assert_character(part, len = 1, min.chars = 1, .var.name = "part")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_integerish(cache_ttl, len = 1, lower = 60, .var.name = "cache_ttl")

  query <- list(part = part, id = channel_id)

  result <- tuber_GET_cached("channels", query, auth, cache_ttl = cache_ttl, ...)

  return(result)
}