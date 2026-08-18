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
  video_file <- tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video_file)
  on.exit(unlink(video_file), add = TRUE)

  calls <- new.env(parent = emptyenv())
  calls$post <- NULL
  calls$put <- NULL
  calls$quota <- NULL

  mock_post <- function(url, query, body, encode, ...) {
    calls$post <- list(url = url, query = query, body = body, encode = encode)
    list(status_code = 200L, headers = list(location = "https://upload.example/session"))
  }
  mock_put <- function(url, body, ...) {
    calls$put <- list(url = url, body = body)
    list(status_code = 201L, content = list(id = "abcdefghijk"))
  }

  local_mocked_bindings(
    POST = mock_post,
    PUT = mock_put,
    status_code = function(response) response$status_code,
    headers = function(response) response$headers,
    content = function(response) response$content,
    yt_check_token = function() invisible(NULL),
    track_quota_usage = function(endpoint, method) {
      calls$quota <- c(endpoint, method)
      invisible(NULL)
    },
    .package = "tuber"
  )

  result <- upload_video(
    file = video_file,
    snippet = list(title = "A title"),
    status = list(privacyStatus = "private")
  )

  expect_equal(calls$post$url, "https://www.googleapis.com/upload/youtube/v3/videos")
  expect_equal(calls$post$query$uploadType, "resumable")
  expect_equal(calls$post$query$part, "snippet,status")
  expect_equal(jsonlite::fromJSON(calls$post$body)$snippet$title, "A title")
  expect_equal(calls$put$url, "https://upload.example/session")
  expect_s3_class(calls$put$body, "form_file")
  expect_equal(calls$quota, c("videos", "insert"))
  expect_equal(result$url, "https://www.youtube.com/watch?v=abcdefghijk")
})

test_that("upload_video requires the Location response header", {
  video_file <- tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video_file)
  on.exit(unlink(video_file), add = TRUE)

  local_mocked_bindings(
    POST = function(...) list(status_code = 200L, headers = list()),
    status_code = function(response) response$status_code,
    headers = function(response) response$headers,
    yt_check_token = function() invisible(NULL),
    track_quota_usage = function(...) invisible(NULL),
    .package = "tuber"
  )

  expect_error(
    upload_video(file = video_file, snippet = list(title = "A title")),
    class = "tuber_upload_location_missing"
  )
})

test_that("upload_caption follows the resumable upload protocol", {
  caption_file <- tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "", "00:00:00.000 --> 00:00:01.000", "Hello"), caption_file)
  on.exit(unlink(caption_file), add = TRUE)

  calls <- new.env(parent = emptyenv())
  calls$post <- NULL
  calls$put <- NULL
  calls$quota <- NULL

  mock_post <- function(url, query, body, encode, ...) {
    calls$post <- list(url = url, query = query, body = body, encode = encode)
    list(status_code = 200L, headers = list(location = "https://upload.example/caption"))
  }
  mock_put <- function(url, body, ...) {
    calls$put <- list(url = url, body = body)
    list(status_code = 201L, content = list(id = "caption-id"))
  }

  local_mocked_bindings(
    POST = mock_post,
    PUT = mock_put,
    status_code = function(response) response$status_code,
    headers = function(response) response$headers,
    content = function(response) response$content,
    tuber_check = function(...) invisible(NULL),
    yt_check_token = function() invisible(NULL),
    track_quota_usage = function(endpoint, method) {
      calls$quota <- c(endpoint, method)
      invisible(NULL)
    },
    .package = "tuber"
  )

  result <- upload_caption(
    file = caption_file,
    video_id = "abcdefghijk",
    caption_name = "English",
    on_behalf_of_content_owner = "owner-1"
  )

  expect_equal(calls$post$url, "https://www.googleapis.com/upload/youtube/v3/captions")
  expect_equal(calls$post$query$uploadType, "resumable")
  expect_equal(calls$post$query$part, "snippet")
  expect_equal(calls$post$query$onBehalfOfContentOwner, "owner-1")
  metadata <- jsonlite::fromJSON(calls$post$body)
  expect_equal(metadata$snippet$videoId, "abcdefghijk")
  expect_equal(metadata$snippet$name, "English")
  expect_equal(calls$put$url, "https://upload.example/caption")
  expect_s3_class(calls$put$body, "form_file")
  expect_equal(calls$quota, c("captions", "insert"))
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
  video_file <- tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video_file)
  on.exit(unlink(video_file), add = TRUE)
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
  on.exit({
    if (is.na(old_key)) Sys.unsetenv("YOUTUBE_KEY") else Sys.setenv(YOUTUBE_KEY = old_key)
  }, add = TRUE)
  Sys.setenv(YOUTUBE_KEY = "cache-key")

  calls <- 0L
  mock_perform <- function(...) {
    calls <<- calls + 1L
    list(status_code = 200L, payload = list(items = list(list(id = "en"))))
  }
  local_mocked_bindings(
    build_httr2_request = function(...) list(),
    req_perform = mock_perform,
    resp_body_json = function(response) response$payload,
    handle_http_response = function(...) invisible(NULL),
    tuber_check = function(...) invisible(NULL),
    track_quota_usage = function(...) invisible(NULL),
    .package = "tuber"
  )

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
  result <- expect_no_warning(suppressMessages(with_retry({
    attempts <- attempts + 1L
    if (attempts == 1L) stop("temporary network timeout")
    "ok"
  }, max_retries = 2, base_delay = 0, jitter = FALSE)))

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
    suppressMessages(with_retry({
      attempts <- attempts + 1L
      tuber:::tuber_check(response)
    }, max_retries = 1L, base_delay = 0, jitter = FALSE)),
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
    get_video_details = function(...) rbind(videos, transform(videos, id = "video000002", statistics_viewCount = "200")),
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
