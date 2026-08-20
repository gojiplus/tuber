test_that("quota estimates are method-aware and bucket-aware", {
  yt_reset_quota()
  on.exit(yt_reset_quota())

  expect_gt(tuber:::.tuber_env$quota_reset_time, Sys.time())

  expect_equal(tuber:::quota_cost("videos", "list"), list(bucket = "data", cost = 1L))
  expect_equal(tuber:::quota_cost("videos", "delete"), list(bucket = "data", cost = 50L))
  expect_equal(tuber:::quota_cost("captions/track", "download"), list(bucket = "data", cost = 200L))
  expect_equal(tuber:::quota_cost("members", "list"), list(bucket = "data", cost = 2L))
  expect_equal(tuber:::quota_cost("search", "list"), list(bucket = "search", cost = 1L))
  expect_equal(tuber:::quota_cost("videos", "insert"), list(bucket = "video_uploads", cost = 1L))

  tuber:::track_quota_usage("videos", "delete")
  tuber:::track_quota_usage("search", "list")
  usage <- yt_get_quota_usage()
  expect_equal(usage$quota_used[usage$bucket == "data"], 50)
  expect_equal(usage$quota_used[usage$bucket == "search"], 1)
})

test_that("upload_video follows the resumable upload protocol", {
  video_file <- withr::local_tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video_file)

  seen <- new.env(parent = emptyenv())

  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(endpoint, method) {
      seen$quota <- c(endpoint, method)
      invisible(NULL)
    },
    .package = "tuber"
  )

  # Mocking at the HTTP layer rather than at httr2's function bindings means
  # the real URL, header and body assembly is what gets asserted on.
  httr2::local_mocked_responses(function(req) {
    if (identical(req$method, "POST")) {
      seen$post <- req
      httr2::response(
        status_code = 200L,
        headers = list(location = "https://upload.example/session")
      )
    } else {
      seen$put <- req
      httr2::response_json(status_code = 201L, body = list(id = "abcdefghijk"))
    }
  })

  result <- upload_video(
    file = video_file,
    snippet = list(title = "A title"),
    status = list(privacyStatus = "private")
  )

  post_url <- httr2::url_parse(seen$post$url)
  expect_equal(post_url$path, "/upload/youtube/v3/videos")
  expect_equal(post_url$query$uploadType, "resumable")
  expect_equal(post_url$query$part, "snippet,status")
  expect_equal(
    jsonlite::fromJSON(as.character(seen$post$body$data))$snippet$title,
    "A title"
  )
  expect_equal(seen$post$headers$`X-Upload-Content-Length`, "10")

  expect_equal(seen$put$url, "https://upload.example/session")
  expect_equal(seen$put$method, "PUT")
  expect_equal(seen$put$body$data, video_file)
  # The bearer token is stored redacted, so it cannot leak through a printed
  # request or an error dump; "reveal" is the only way to see it.
  expect_equal(
    httr2::req_get_headers(seen$put, "reveal")$Authorization,
    "Bearer fake-token"
  )
  expect_equal(
    httr2::req_get_headers(seen$put, "redact")$Authorization,
    "<REDACTED>"
  )

  expect_equal(seen$quota, c("videos", "insert"))
  expect_equal(result$url, "https://www.youtube.com/watch?v=abcdefghijk")
})

test_that("upload_video requires the Location response header", {
  video_file <- withr::local_tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video_file)

  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(...) invisible(NULL),
    .package = "tuber"
  )
  httr2::local_mocked_responses(list(httr2::response(status_code = 200L)))

  expect_error(
    upload_video(file = video_file, snippet = list(title = "A title")),
    class = "tuber_upload_location_missing"
  )
})

test_that("upload_caption follows the resumable upload protocol", {
  caption_file <- withr::local_tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "", "00:00:00.000 --> 00:00:01.000", "Hello"), caption_file)

  seen <- new.env(parent = emptyenv())

  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(endpoint, method) {
      seen$quota <- c(endpoint, method)
      invisible(NULL)
    },
    .package = "tuber"
  )

  httr2::local_mocked_responses(function(req) {
    if (identical(req$method, "POST")) {
      seen$post <- req
      httr2::response(
        status_code = 200L,
        headers = list(location = "https://upload.example/caption")
      )
    } else {
      seen$put <- req
      httr2::response_json(status_code = 201L, body = list(id = "caption-id"))
    }
  })

  result <- upload_caption(
    file = caption_file,
    video_id = "abcdefghijk",
    caption_name = "English",
    on_behalf_of_content_owner = "owner-1"
  )

  post_url <- httr2::url_parse(seen$post$url)
  expect_equal(post_url$path, "/upload/youtube/v3/captions")
  expect_equal(post_url$query$uploadType, "resumable")
  expect_equal(post_url$query$part, "snippet")
  expect_equal(post_url$query$onBehalfOfContentOwner, "owner-1")

  metadata <- jsonlite::fromJSON(as.character(seen$post$body$data))
  expect_equal(metadata$snippet$videoId, "abcdefghijk")
  expect_equal(metadata$snippet$name, "English")

  expect_equal(seen$put$url, "https://upload.example/caption")
  expect_equal(seen$put$body$data, caption_file)
  expect_equal(seen$quota, c("captions", "insert"))
  expect_equal(result$content$id, "caption-id")
})

test_that("upload APIs expose supported query options explicitly", {
  expect_false("query" %in% names(formals(upload_video)))
  expect_false("query" %in% names(formals(upload_caption)))
  expect_true(all(c(
    "notify_subscribers",
    "on_behalf_of_content_owner",
    "content_owner_channel_id"
  ) %in% names(formals(upload_video))))
  video_file <- withr::local_tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video_file)
  expect_error(
    upload_video(file = video_file, on_behalf_of_content_owner = "owner"),
    class = "tuber_conflicting_parameters"
  )
})

test_that("public collection functions use one naming grammar", {
  exports <- getNamespaceExports("tuber")
  canonical <- c(
    "list_comments",
    "list_comment_threads",
    "list_playlist_items",
    "list_playlists",
    "list_subscriptions",
    "list_live_chat_messages",
    "list_super_chat_events"
  )
  retired <- sub("^list_", "get_", canonical)

  expect_true(all(canonical %in% exports))
  expect_false(any(retired %in% exports))
})

test_that("public reads default to API-key authentication", {
  public_reads <- c(
    "get_video_details",
    "get_video_stats",
    "yt_search",
    "list_comments",
    "list_comment_threads",
    "list_playlist_items",
    "list_popular_videos"
  )
  defaults <- vapply(public_reads, function(name) {
    eval(formals(getExportedValue("tuber", name))$auth)
  }, character(1))
  expect_true(all(defaults == "key"))
})

test_that("simplified collection results have stable snake-case empty schemas", {
  empty_response <- list(
    items = list(),
    nextPageToken = NULL,
    pageInfo = list(totalResults = 0L, resultsPerPage = 0L)
  )
  local_mocked_bindings(
    tuber_GET = function(...) empty_response,
    .package = "tuber"
  )

  results <- list(
    list_comments(parent_id = "parent"),
    list_comment_threads(video_id = "abcdefghijk"),
    list_playlist_items(playlist_id = "playlist"),
    list_playlists(channel_id = "channel"),
    list_subscriptions(channel_id = "channel"),
    list_channel_activities(channel_id = "channel"),
    list_channel_sections(channel_id = "channel"),
    list_live_broadcasts(status = "completed"),
    list_live_chat_messages(live_chat_id = "chat"),
    list_super_chat_events(),
    list_channel_members(),
    list_captions(video_id = "abcdefghijk"),
    list_popular_videos(),
    yt_search("topic")
  )

  for (result in results) {
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0L)
    expect_gt(ncol(result), 0L)
    expect_true(all(grepl("^[a-z][a-z0-9_]*$", names(result))))
  }
})

test_that("cache keys isolate credentials and persistent cache round-trips", {
  cache_dir <- tempfile("tuber-cache-")
  dir.create(cache_dir)
  on.exit(unlink(cache_dir, recursive = TRUE), add = TRUE)

  tuber_cache_config(cache_dir = cache_dir)
  on.exit(tuber_cache_config(cache_dir = NULL), add = TRUE)
  tuber_cache_clear()

  old_token <- getOption("google_token")
  on.exit(options(google_token = old_token), add = TRUE)
  options(google_token = list(credentials = list(access_token = "token-a")))
  key_a <- tuber:::generate_cache_key("channels", list(part = "snippet", mine = TRUE), "token")
  options(google_token = list(credentials = list(access_token = "token-b")))
  key_b <- tuber:::generate_cache_key("channels", list(part = "snippet", mine = TRUE), "token")
  expect_false(identical(key_a, key_b))

  tuber:::store_cached_response(key_b, list(items = list(list(id = "channel-b"))))
  rm(list = key_b, envir = tuber:::.tuber_cache)
  expect_equal(tuber:::get_cached_response(key_b)$items[[1]]$id, "channel-b")
})

test_that("ordinary GET wrappers use the transparent cache", {
  tuber_cache_config(enabled = TRUE, cache_dir = NULL)
  tuber_cache_clear()
  old_key <- Sys.getenv("YOUTUBE_KEY", unset = NA_character_)
  on.exit(
    {
      if (is.na(old_key)) Sys.unsetenv("YOUTUBE_KEY") else Sys.setenv(YOUTUBE_KEY = old_key)
    },
    add = TRUE
  )
  Sys.setenv(YOUTUBE_KEY = "cache-key")

  calls <- 0L
  local_mocked_bindings(track_quota_usage = function(...) invisible(NULL), .package = "tuber")
  httr2::local_mocked_responses(function(req) {
    calls <<- calls + 1L
    httr2::response_json(status_code = 200L, body = list(items = list(list(id = "en"))))
  })

  first <- tuber:::tuber_GET("i18nLanguages", list(part = "snippet"), auth = "key")
  second <- tuber:::tuber_GET("i18nLanguages", list(part = "snippet"), auth = "key")
  expect_equal(calls, 1L)
  expect_equal(first, second, ignore_attr = TRUE)
  expect_true(isTRUE(attr(second, "tuber_cache_hit")))
})

test_that("mutable channel and video resources are never cached", {
  expect_false(tuber:::is_cacheable_endpoint("channels"))
  expect_false(tuber:::is_cacheable_endpoint("videos"))
  expect_false(tuber:::is_static_query(
    "videos",
    list(part = "snippet,contentDetails", id = "video00001")
  ))
  expect_false(tuber:::is_static_query(
    "videos",
    list(part = "snippet", chart = "mostPopular")
  ))
  expect_false(tuber:::is_static_query(
    "videos",
    list(part = "snippet", myRating = "like")
  ))
})

test_that("httr2 failures become tuber HTTP errors", {
  response <- httr2::response(
    status_code = 400,
    body = charToRaw('{"error":{"message":"bad request"}}'),
    headers = list("content-type" = "application/json")
  )
  expect_error(
    tuber:::tuber_check(response),
    "bad request",
    class = "tuber_http_error"
  )
})

test_that("with_retry re-evaluates transient failures without promise warnings", {
  attempts <- 0L
  result <- expect_no_warning(suppressMessages(with_retry(
    {
      attempts <- attempts + 1L
      if (attempts == 1L) stop("temporary network timeout")
      "ok"
    },
    max_retries = 2,
    base_delay = 0,
    jitter = FALSE
  )))

  expect_equal(result, "ok")
  expect_equal(attempts, 2L)
})

test_that("with_retry uses HTTP status and preserves the original condition", {
  attempts <- 0L
  response <- httr2::response(
    status_code = 503L,
    body = charToRaw('{"error":{"message":"maintenance"}}'),
    headers = list("content-type" = "application/json")
  )

  error <- tryCatch(
    suppressMessages(with_retry(
      {
        attempts <- attempts + 1L
        tuber:::tuber_check(response)
      },
      max_retries = 1L,
      base_delay = 0,
      jitter = FALSE
    )),
    error = identity
  )

  expect_equal(attempts, 2L)
  expect_s3_class(error, "tuber_http_error")
  expect_equal(error$status_code, 503L)
  expect_equal(error$retry_attempts, 1L)
  expect_false(tuber:::is_transient_error(rlang::error_cnd(
    class = "tuber_http_error",
    message = "bad request",
    status_code = 400L
  )))
})

test_that("high-level analyses consume current simplified return contracts", {
  channel <- data.frame(
    channel_id = "UC1",
    title = "Channel",
    uploads_playlist = "UU1",
    stringsAsFactors = FALSE
  )
  playlist <- list(items = list(
    list(snippet = list(resourceId = list(videoId = "video000001")))
  ))
  videos <- data.frame(
    id = "video000001",
    snippet_title = "Video",
    statistics_viewCount = "100",
    statistics_likeCount = "10",
    statistics_commentCount = "2",
    stringsAsFactors = FALSE
  )

  local_mocked_bindings(
    get_channel_details = function(...) channel,
    list_playlist_items = function(...) playlist,
    get_video_details = function(...) videos,
    .package = "tuber"
  )
  channel_result <- analyze_channel("UC1")
  expect_equal(channel_result$performance_metrics$total_recent_views, 100)
  expect_equal(channel_result$performance_metrics$top_performing_video$snippet_title, "Video")

  search <- data.frame(
    video_id = "video000001",
    title = "Video",
    channel_title = "Channel",
    published_at = "2026-01-01T00:00:00Z",
    stringsAsFactors = FALSE
  )
  local_mocked_bindings(
    yt_search = function(...) search,
    get_video_details = function(...) videos,
    .package = "tuber"
  )
  trend_result <- analyze_trends("topic")
  expect_equal(nrow(trend_result$detailed_results), 1)
  expect_equal(trend_result$detailed_results$view_count, 100)

  local_mocked_bindings(
    get_video_details = function(...) {
      rbind(videos, transform(
        videos,
        id = "video000002", statistics_viewCount = "200"
      ))
    },
    get_all_comments = function(...) data.frame(id = c("c1", "c2")),
    .package = "tuber"
  )
  bulk_result <- bulk_video_analysis(
    c("video000001", "video000002"),
    include_comments = TRUE
  )
  expect_equal(bulk_result$summary$total_views, 300)
  expect_equal(bulk_result$video_data$comments_retrieved, c(2L, 2L))
})

test_that("own-channel video statistics resolve the uploads playlist", {
  own_channel <- list(
    id = "UC1",
    contentDetails = list(relatedPlaylists = list(uploads = "UU1"))
  )
  playlist <- list(
    items = list(list(contentDetails = list(videoId = "video000001"))),
    nextPageToken = NULL
  )
  videos <- data.frame(
    id = "video000001",
    snippet_title = "Video",
    snippet_publishedAt = "2026-01-01T00:00:00Z",
    snippet_description = "Description",
    snippet_channelId = "UC1",
    snippet_channelTitle = "Channel",
    statistics_viewCount = "100",
    statistics_likeCount = "10",
    statistics_commentCount = "2",
    stringsAsFactors = FALSE
  )

  local_mocked_bindings(
    get_channel_details = function(...) list(items = list(own_channel)),
    list_playlist_items = function(...) playlist,
    get_video_details = function(...) videos,
    .package = "tuber"
  )

  result <- suppressMessages(get_all_channel_video_stats(mine = TRUE))
  expect_equal(result$video_id, "video000001")
  expect_equal(result$channel_id, "UC1")
})

test_that("subsetting tuber results does not duplicate the class", {
  result <- tuber:::add_tuber_attributes(data.frame(x = 1:2))
  subset <- result[1, , drop = FALSE]
  expect_equal(sum(class(subset) == "tuber_result"), 1)
})

test_that("trend analysis handles search hits with no accessible details", {
  search <- data.frame(
    video_id = "video000001",
    title = "Video",
    channel_title = "Channel",
    published_at = "2026-01-01T00:00:00Z",
    stringsAsFactors = FALSE
  )
  local_mocked_bindings(
    yt_search = function(...) search,
    get_video_details = function(...) data.frame(id = character()),
    .package = "tuber"
  )

  result <- suppressMessages(analyze_trends("topic"))
  expect_equal(nrow(result$detailed_results), 1L)
  expect_true(is.na(result$detailed_results$view_count))
})

test_that("bulk comment counts align with returned video IDs", {
  videos <- data.frame(
    id = "video000002",
    snippet_title = "Video",
    statistics_viewCount = "20",
    statistics_likeCount = "2",
    statistics_commentCount = "1",
    stringsAsFactors = FALSE
  )
  requested <- character()
  local_mocked_bindings(
    get_video_details = function(...) videos,
    get_all_comments = function(video_id, ...) {
      requested <<- c(requested, video_id)
      data.frame(comment_id = c("c1", "c2"))
    },
    .package = "tuber"
  )

  result <- suppressMessages(bulk_video_analysis(
    c("video000001", "video000002", "video000002"),
    include_comments = TRUE
  ))
  expect_equal(requested, "video000002")
  expect_equal(result$video_data$comments_retrieved, 2L)
})

test_that("empty short-video searches preserve the empty schema", {
  empty <- data.frame(video_id = character(), title = character())
  local_mocked_bindings(
    yt_search = function(...) empty,
    .package = "tuber"
  )

  result <- search_short_videos("topic")
  expect_equal(nrow(result), 0L)
  expect_type(result$duration_filter, "character")
  expect_length(result$duration_filter, 0L)
})

test_that("raw paginated results expose the final page token", {
  paged_get <- function(...) {
    token <- list(...)$query$pageToken
    if (is.null(token)) {
      list(items = list(list(id = "first")), nextPageToken = "page-2")
    } else {
      list(items = list(list(id = "second")), nextPageToken = "page-3")
    }
  }
  local_mocked_bindings(tuber_GET = paged_get, .package = "tuber")

  results <- list(
    list_popular_videos(max_results = 2, simplify = FALSE),
    list_channel_members(max_results = 2, simplify = FALSE),
    list_live_chat_messages("chat", max_results = 2, simplify = FALSE),
    list_super_chat_events(max_results = 2, simplify = FALSE)
  )
  for (result in results) {
    expect_equal(length(result$items), 2L)
    expect_equal(result$nextPageToken, "page-3")
  }
})

test_that("empty fetched pages advance pagination metadata", {
  pages <- tuber:::paginate_api_request(
    initial_response = list(
      items = list(list(id = "first")),
      nextPageToken = "page-2"
    ),
    fetch_next_page_fn = function(token) {
      expect_equal(token, "page-2")
      list(items = list(), nextPageToken = "page-3")
    },
    max_results = 2
  )

  expect_equal(pages$page_count, 2L)
  expect_equal(pages$final_page_token, "page-3")
  expect_true(pages$has_more)
})

test_that("OAuth reads carry a redacted bearer token", {
  seen <- new.env(parent = emptyenv())

  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(...) invisible(NULL),
    .package = "tuber"
  )
  httr2::local_mocked_responses(function(req) {
    seen$req <- req
    httr2::response_json(status_code = 200L, body = list(items = list()))
  })

  tuber:::tuber_GET("subscriptions", list(part = "snippet", mine = "true"))

  url <- httr2::url_parse(seen$req$url)
  expect_equal(url$path, "/youtube/v3/subscriptions")
  expect_equal(url$query$mine, "true")
  expect_equal(httr2::req_get_headers(seen$req, "reveal")$Authorization, "Bearer fake-token")
  expect_equal(httr2::req_get_headers(seen$req, "redact")$Authorization, "<REDACTED>")
  expect_null(httr2::req_get_headers(seen$req, "reveal")$`x-goog-api-key`)
})

test_that("caption downloads come back as raw bytes, not parsed JSON", {
  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(...) invisible(NULL),
    .package = "tuber"
  )
  httr2::local_mocked_responses(list(httr2::response(
    status_code = 200L,
    headers = list("content-type" = "text/vtt"),
    body = charToRaw("WEBVTT\n")
  )))

  res <- tuber:::tuber_GET("captions/abc123", list(tfmt = "vtt"))
  expect_type(res, "raw")
  expect_equal(rawToChar(res), "WEBVTT\n")
})

test_that("a DELETE that returns 204 does not try to parse a body", {
  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(...) invisible(NULL),
    .package = "tuber"
  )
  httr2::local_mocked_responses(list(httr2::response(status_code = 204L)))

  expect_silent(res <- tuber:::tuber_DELETE("videos", list(id = "abc")))
  expect_equal(res, raw(0))
})
