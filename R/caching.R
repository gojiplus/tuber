#' Response Caching for YouTube API
#'
#' Implements intelligent caching for static YouTube API data to reduce quota usage
#' and improve performance. Particularly useful for video categories, regions,
#' languages, and other data that changes infrequently.
#'
#' @name caching
#' @keywords internal
NULL

# Global environment for cache storage
.tuber_cache <- new.env(parent = emptyenv())
.tuber_cache$config <- list(
  enabled = TRUE,
  default_ttl = 3600L,
  max_size = 1000L,
  cache_dir = NULL,
  created_at = Sys.time()
)

cache_file_path <- function(cache_key) {
  cache_dir <- .tuber_cache$config$cache_dir %||% NULL
  if (is.null(cache_dir)) return(NULL)
  file.path(cache_dir, paste0(cache_key, ".rds"))
}

auth_fingerprint <- function(auth) {
  credential <- if (auth == "key") {
    suppressMessages(yt_get_key()) %||% "missing-key"
  } else {
    token <- yt_token()
    if (is.null(token)) {
      "missing-token"
    } else {
      tryCatch(token$credentials$access_token, error = function(e) NULL) %||%
        digest(token)
    }
  }
  digest(credential, algo = "sha256")
}

#' Configure caching settings
#'
#' @param enabled Whether to enable caching globally
#' @param default_ttl Default time-to-live in seconds
#' @param max_size Maximum number of cached items
#' @param cache_dir Directory for persistent cache (NULL for memory only)
#' @export
tuber_cache_config <- function(enabled = TRUE,
                               default_ttl = 3600, # 1 hour
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
  config <- .tuber_cache$config

  # Add runtime stats
  memory_keys <- ls(.tuber_cache, pattern = "^cache_")
  disk_files <- if (is.null(config$cache_dir)) {
    character()
  } else {
    list.files(config$cache_dir, pattern = "^cache_.*\\.rds$", full.names = TRUE)
  }
  config$items_cached <- length(unique(c(
    memory_keys,
    sub("\\.rds$", "", basename(disk_files))
  )))
  config$items_in_memory <- length(memory_keys)
  config$items_on_disk <- length(disk_files)
  config$memory_usage <- format(object.size(.tuber_cache), units = "MB")

  config
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

  memory_keys <- ls(.tuber_cache, pattern = "^cache_")
  cache_dir <- .tuber_cache$config$cache_dir %||% NULL
  disk_files <- if (is.null(cache_dir)) {
    character()
  } else {
    list.files(cache_dir, pattern = "^cache_.*\\.rds$", full.names = TRUE)
  }
  disk_keys <- sub("\\.rds$", "", basename(disk_files))
  cache_keys <- unique(c(memory_keys, disk_keys))

  if (!is.null(pattern)) {
    cache_keys <- cache_keys[grepl(pattern, cache_keys)]
  }

  cleared_count <- 0

  for (key in cache_keys) {
    should_clear <- TRUE

    if (!is.null(older_than)) {
      cache_entry <- if (exists(key, envir = .tuber_cache, inherits = FALSE)) {
        get(key, envir = .tuber_cache, inherits = FALSE)
      } else {
        cache_file <- cache_file_path(key)
        tryCatch(readRDS(cache_file), error = function(e) NULL)
      }
      should_clear <- is.null(cache_entry) ||
        as.numeric(difftime(Sys.time(), cache_entry$created_at, units = "secs")) > older_than
    }

    if (should_clear) {
      if (exists(key, envir = .tuber_cache, inherits = FALSE)) {
        rm(list = key, envir = .tuber_cache)
      }
      cache_file <- cache_file_path(key)
      if (!is.null(cache_file) && file.exists(cache_file)) unlink(cache_file)
      cleared_count <- cleared_count + 1
    }
  }

  message("Cleared ", cleared_count, " cache entries")
  invisible(cleared_count)
}

#' Generate cache key for API request
#'
#' @param endpoint API endpoint name
#' @param query Query parameters
#' @param auth Authentication method
#' @return Character cache key
#' @keywords internal
generate_cache_key <- function(endpoint, query, auth) {
  # Sort query parameters for consistent keys
  query_sorted <- query[sort(names(query))]
  query_str <- paste(names(query_sorted), query_sorted, sep = "=", collapse = "&")

  key_parts <- c(endpoint, auth, auth_fingerprint(auth), query_str)
  cache_key <- paste0("cache_", digest(key_parts, algo = "md5"))

  cache_key
}

#' Check if endpoint should be cached
#'
#' @param endpoint API endpoint name
#' @return Logical indicating if endpoint is cacheable
#' @keywords internal
is_cacheable_endpoint <- function(endpoint) {
  endpoint %in% c("videoCategories", "i18nLanguages", "i18nRegions")
}

#' Check if query parameters indicate static data
#'
#' @param endpoint API endpoint
#' @param query Query parameters
#' @return Logical indicating if this specific query is cacheable
#' @keywords internal
is_static_query <- function(endpoint, query) {
  # Video categories - always static
  if (endpoint == "videoCategories") return(TRUE)

  # Languages and regions - always static
  if (endpoint %in% c("i18nLanguages", "i18nRegions")) return(TRUE)

  FALSE
}

#' Get cached response if available and valid
#'
#' @param cache_key Cache key
#' @return Cached response or NULL if not available/expired
#' @keywords internal
get_cached_response <- function(cache_key) {
  config <- .tuber_cache$config
  if (!config$enabled) return(NULL)

  cache_entry <- if (exists(cache_key, envir = .tuber_cache)) {
    get(cache_key, envir = .tuber_cache)
  } else {
    cache_file <- cache_file_path(cache_key)
    if (is.null(cache_file) || !file.exists(cache_file)) return(NULL)
    tryCatch(readRDS(cache_file), error = function(e) NULL)
  }
  if (is.null(cache_entry)) return(NULL)

  # Check if expired
  age <- as.numeric(difftime(Sys.time(), cache_entry$created_at, units = "secs"))
  if (age > cache_entry$ttl) {
    if (exists(cache_key, envir = .tuber_cache)) {
      rm(list = cache_key, envir = .tuber_cache)
    }
    cache_file <- cache_file_path(cache_key)
    if (!is.null(cache_file) && file.exists(cache_file)) unlink(cache_file)
    return(NULL)
  }

  assign(cache_key, cache_entry, envir = .tuber_cache)
  cache_entry$data
}

#' Store response in cache
#'
#' @param cache_key Cache key
#' @param data Response data to cache
#' @param ttl Time-to-live in seconds (NULL for default)
#' @keywords internal
store_cached_response <- function(cache_key, data, ttl = NULL) {
  config <- .tuber_cache$config
  if (!config$enabled) return(invisible(NULL))

  # Use default TTL if not specified
  if (is.null(ttl)) {
    ttl <- config$default_ttl %||% 3600
  }

  # Check cache size limits across memory and persistent storage.
  memory_keys <- ls(.tuber_cache, pattern = "^cache_")
  disk_files <- if (is.null(config$cache_dir)) {
    character()
  } else {
    list.files(config$cache_dir, pattern = "^cache_.*\\.rds$", full.names = TRUE)
  }
  cache_keys <- unique(c(memory_keys, sub("\\.rds$", "", basename(disk_files))))
  current_size <- length(cache_keys)
  max_size <- config$max_size %||% 1000

  if (current_size >= max_size) {
    created_at <- vapply(cache_keys, function(key) {
      entry <- if (exists(key, envir = .tuber_cache, inherits = FALSE)) {
        get(key, envir = .tuber_cache, inherits = FALSE)
      } else {
        tryCatch(readRDS(cache_file_path(key)), error = function(e) NULL)
      }
      if (is.null(entry)) Inf else as.numeric(entry$created_at)
    }, numeric(1))
    oldest_keys <- cache_keys[order(created_at)][seq_len(current_size - max_size + 1)]
    memory_oldest <- oldest_keys[vapply(
      oldest_keys,
      exists,
      logical(1),
      envir = .tuber_cache,
      inherits = FALSE
    )]
    if (length(memory_oldest) > 0) rm(list = memory_oldest, envir = .tuber_cache)
    for (key in oldest_keys) {
      cache_file <- cache_file_path(key)
      if (!is.null(cache_file) && file.exists(cache_file)) unlink(cache_file)
    }
  }

  # Store cache entry
  cache_entry <- list(
    data = data,
    created_at = Sys.time(),
    ttl = ttl
  )

  assign(cache_key, cache_entry, envir = .tuber_cache)
  cache_file <- cache_file_path(cache_key)
  if (!is.null(cache_file)) saveRDS(cache_entry, cache_file)
  invisible(NULL)
}
