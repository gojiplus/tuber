# Each test here failed against the code as it stood before the November 2026
# audit; the name states the defect it guards.

json_response <- function(body, status = 200L) {
  httr2::response_json(status_code = status, body = body)
}

local_fake_token <- function(env = parent.frame()) {
  withr::local_options(
    google_token = httr2::oauth_token("fake-token", expires_in = 3600),
    .local_envir = env
  )
}

# Serializes the body exactly as httr2 will put it on the wire.
request_json <- function(req) {
  as.character(do.call(jsonlite::toJSON, c(list(req$body$data), req$body$params)))
}

# A playlist of `total` items that honours maxResults, optionally capping the
# first page to imitate YouTube returning a short page with a next token.
playlist_pages <- function(total, first_page_cap = Inf) {
  function(path, query, ...) {
    start <- as.integer(query$pageToken %||% 0L)
    cap <- if (start == 0L) first_page_cap else Inf
    n <- min(query$maxResults, total - start, cap)
    list(
      items = lapply(start + seq_len(n), function(i) {
        list(
          id = sprintf("item%03d", i),
          contentDetails = list(videoId = sprintf("vid%03d", i))
        )
      }),
      nextPageToken = if (start + n < total) as.character(start + n)
    )
  }
}

# Unknown arguments ----------------------------------------------------------

test_that("a misspelled argument is an error, not silently ignored", {
  local_mocked_bindings(tuber_GET = function(...) list(items = list()))

  expect_error(
    list_playlists(channel_id = "UCabc", simplfy = FALSE),
    "unused argument"
  )
})

test_that("no exported function swallows arguments through dots", {
  ns <- asNamespace("tuber")
  takes_dots <- Filter(function(name) {
    fn <- get(name, envir = ns)
    is.function(fn) && "..." %in% names(formals(fn))
  }, getNamespaceExports("tuber"))

  # yt_oauth() forwards its dots to httr2::oauth_flow_auth_code(), which
  # rejects what it does not know.
  expect_setequal(takes_dots, "yt_oauth")
})

# Pagination -----------------------------------------------------------------

test_that("nextPageToken resumes at the item after the last one returned", {
  local_mocked_bindings(tuber_GET = playlist_pages(200))

  first <- list_playlist_items(
    playlist_id = "PLx", max_results = 120, simplify = FALSE
  )
  expect_length(first$items, 120)
  expect_equal(first$nextPageToken, "120")

  rest <- list_playlist_items(
    playlist_id = "PLx",
    max_results = 50,
    page_token = first$nextPageToken,
    simplify = FALSE
  )
  expect_equal(rest$items[[1]]$id, "item121")
})

test_that("get_all_channel_video_stats keeps every video after a short page", {
  seen <- new.env(parent = emptyenv())
  local_mocked_bindings(
    get_channel_details = function(...) {
      list(items = list(list(
        contentDetails = list(relatedPlaylists = list(uploads = "UUx"))
      )))
    },
    tuber_GET = playlist_pages(108, first_page_cap = 48),
    get_video_details = function(video_ids, ...) {
      seen$ids <- video_ids
      data.frame(id = video_ids, stringsAsFactors = FALSE)
    }
  )

  suppressMessages(get_all_channel_video_stats(channel_id = "UCx"))

  expect_equal(seen$ids, sprintf("vid%03d", 1:108))
})

# OAuth cache ----------------------------------------------------------------

test_that("a token loaded from the cache can still be refreshed", {
  tf <- withr::local_tempfile(fileext = ".rds")
  withr::local_options(google_token = NULL, tuber.oauth_client = NULL)
  expired <- httr2::oauth_token(
    "stale", refresh_token = "refresh-me", expires_in = -1000
  )

  local_mocked_bindings(
    oauth_flow_auth_code = function(...) expired,
    oauth_flow_refresh = function(client, refresh_token, ...) {
      expect_equal(client$id, "id")
      httr2::oauth_token("fresh", refresh_token = refresh_token)
    }
  )
  yt_oauth(app_id = "id", app_secret = "secret", token = tf)

  # A new session: nothing in options, and no credentials passed.
  options(google_token = NULL, tuber.oauth_client = NULL)
  yt_oauth(token = tf)

  expect_equal(tuber:::yt_access_token(), "fresh")
})

test_that("an unrefreshable token says how to recover in the message itself", {
  withr::local_options(
    google_token = httr2::oauth_token(
      "stale", refresh_token = "r", expires_in = -1000
    ),
    tuber.oauth_client = NULL
  )

  expect_error(tuber:::yt_access_token(), "yt_oauth\\(")
})

# HTTP error translation -----------------------------------------------------

test_that("tuber_check reports a 403 whose body lacks error$message", {
  for (body in c('{"error":"access_denied"}', "{}", '{"error":{"code":403}}')) {
    resp <- httr2::response(status_code = 403L, body = charToRaw(body))
    expect_error(tuber:::tuber_check(resp), class = "tuber_http_error")
  }
})

test_that("an HTTP error carries YouTube's reason code", {
  resp <- json_response(
    list(error = list(
      code = 403,
      message = "The video has disabled comments.",
      errors = list(list(reason = "commentsDisabled"))
    )),
    status = 403L
  )

  err <- expect_error(tuber:::tuber_check(resp), class = "tuber_http_error")
  expect_equal(err$reason, "commentsDisabled")
})

test_that("get_all_comments does not mistake a disabled API for disabled comments", {
  withr::local_envvar(YOUTUBE_KEY = "fake-key")
  httr2::local_mocked_responses(function(req) {
    json_response(
      list(error = list(
        code = 403,
        message = paste(
          "YouTube Data API v3 has not been used in project 1 before",
          "or it is disabled."
        ),
        errors = list(list(reason = "accessNotConfigured"))
      )),
      status = 403L
    )
  })

  expect_error(
    get_all_comments("abcdefghijk"),
    class = "tuber_comment_fetch_error"
  )
})

test_that("get_all_comments still reports genuinely disabled comments", {
  withr::local_envvar(YOUTUBE_KEY = "fake-key")
  httr2::local_mocked_responses(function(req) {
    json_response(
      list(error = list(
        code = 403,
        message = "The video identified by the videoId parameter has disabled comments.",
        errors = list(list(reason = "commentsDisabled"))
      )),
      status = 403L
    )
  })

  warned <- character()
  result <- withCallingHandlers(
    get_all_comments("abcdefghijk"),
    warning = function(w) {
      warned <<- c(warned, class(w)[[1]])
      invokeRestart("muffleWarning")
    }
  )

  expect_equal(warned, "tuber_comments_disabled")
  expect_equal(nrow(result), 0)
})

# Write bodies ---------------------------------------------------------------

test_that("update_video_metadata sends a single tag as a JSON array", {
  local_fake_token()
  seen <- new.env(parent = emptyenv())
  httr2::local_mocked_responses(function(req) {
    if (!is.null(req$body)) {
      seen$json <- request_json(req)
      return(json_response(list(id = "abcdefghijk")))
    }
    json_response(list(items = list(list(
      id = "abcdefghijk",
      snippet = list(title = "T", categoryId = "22", tags = list("old1", "old2"))
    ))))
  })

  update_video_metadata("abcdefghijk", tags = "newtag")
  expect_match(seen$json, '"tags":["newtag"]', fixed = TRUE)

  update_video_metadata("abcdefghijk", tags = character())
  expect_match(seen$json, '"tags":[]', fixed = TRUE)
})

test_that("post_comment requires a video", {
  local_fake_token()
  expect_error(post_comment(channel_id = "UCx", text = "hi"), "video_id")
})

test_that("set_comment_moderation_status names its vector argument in the plural", {
  expect_true("comment_ids" %in% names(formals(set_comment_moderation_status)))
})

# Captions -------------------------------------------------------------------

test_that("read_sbv keeps captions that span several lines", {
  path <- withr::local_tempfile(fileext = ".sbv")
  writeLines(c(
    "0:00:01.000,0:00:03.000", "Hello there", "",
    "0:00:03.500,0:00:06.000", "This caption", "wraps to two lines", "",
    "0:00:06.500,0:00:09.000", "Third caption"
  ), path)

  captions <- read_sbv(path)

  expect_equal(captions$start, c("0:00:01.000", "0:00:03.500", "0:00:06.500"))
  expect_equal(captions$stop, c("0:00:03.000", "0:00:06.000", "0:00:09.000"))
  expect_equal(
    captions$text,
    c("Hello there", "This caption\nwraps to two lines", "Third caption")
  )
})

test_that("read_sbv keeps file order past the ten-hour mark", {
  path <- withr::local_tempfile(fileext = ".sbv")
  writeLines(c(
    "9:59:58.000,9:59:59.000", "before", "",
    "10:00:00.000,10:00:01.000", "after", ""
  ), path)

  expect_equal(read_sbv(path)$text, c("before", "after"))
})

# Derived analyses -----------------------------------------------------------

test_that("analyze_channel aligns comment counts when an upload is unavailable", {
  local_mocked_bindings(
    get_channel_details = function(...) {
      data.frame(channel_id = "UCx", uploads_playlist = "UUx")
    },
    list_playlist_items = function(...) {
      list(items = lapply(c("v1", "v2", "v3"), function(id) {
        list(snippet = list(resourceId = list(videoId = id)))
      }))
    },
    get_video_details = function(video_ids, ...) {
      data.frame(
        id = c("v1", "v3"),
        snippet_title = c("a", "c"),
        statistics_viewCount = c("10", "30"),
        statistics_likeCount = c("1", "3"),
        statistics_commentCount = c("0", "0")
      )
    },
    get_all_comments = function(video_id, ...) {
      data.frame(x = seq_len(match(video_id, c("v1", "v2", "v3"))))
    }
  )

  analysis <- suppressMessages(analyze_channel("UCx", include_comments = TRUE))

  expect_equal(analysis$recent_videos$id, c("v1", "v3"))
  expect_equal(analysis$recent_videos$comments_retrieved, c(1L, 3L))
})

test_that("get_all_channel_video_stats returns numeric counts under published_at", {
  local_mocked_bindings(
    get_channel_details = function(...) {
      list(items = list(list(
        contentDetails = list(relatedPlaylists = list(uploads = "UUx"))
      )))
    },
    tuber_GET = playlist_pages(2),
    get_video_details = function(video_ids, ...) {
      data.frame(
        id = video_ids,
        snippet_title = c("a", "b"),
        snippet_publishedAt = c("2024-01-01T00:00:00Z", "2024-01-02T00:00:00Z"),
        statistics_viewCount = c("10", "20"),
        statistics_likeCount = c("1", "2"),
        statistics_commentCount = c("0", "5"),
        stringsAsFactors = FALSE
      )
    }
  )

  stats <- suppressMessages(get_all_channel_video_stats(channel_id = "UCx"))

  expect_equal(stats$published_at, c("2024-01-01T00:00:00Z", "2024-01-02T00:00:00Z"))
  expect_identical(stats$view_count, c(10, 20))
  expect_identical(stats$comment_count, c(0, 5))
})

test_that("get_all_channel_video_stats keeps its columns for an empty channel", {
  local_mocked_bindings(
    get_channel_details = function(...) {
      list(items = list(list(
        contentDetails = list(relatedPlaylists = list(uploads = "UUx"))
      )))
    },
    tuber_GET = playlist_pages(0)
  )

  stats <- suppressMessages(suppressWarnings(
    get_all_channel_video_stats(channel_id = "UCx")
  ))

  expect_equal(nrow(stats), 0)
  expect_named(stats, c(
    "video_id", "title", "published_at", "description", "channel_id",
    "channel_title", "view_count", "like_count", "comment_count", "url"
  ))
})

# Search ---------------------------------------------------------------------

test_that("yt_search date validation does not depend on the local time zone", {
  local_mocked_bindings(tuber_GET = function(...) list(items = list()))
  withr::local_timezone("America/Los_Angeles")

  # 02:30 on this date does not exist in Los Angeles, but it does in UTC.
  expect_no_error(yt_search("x", published_after = "2026-03-08T02:30:00Z"))
  expect_no_error(yt_search("x", published_after = "2026-03-08T02:30:00+05:30"))
  expect_error(
    yt_search("x", published_after = "March 8, 2026"),
    class = "tuber_invalid_date_format"
  )
})

test_that("yt_search prefers English by default and NULL turns that off", {
  seen <- new.env(parent = emptyenv())
  local_mocked_bindings(tuber_GET = function(path, query, ...) {
    seen$query <- query
    list(items = list())
  })

  yt_search("x")
  expect_equal(seen$query$relevanceLanguage, "en")

  yt_search("x", relevance_language = NULL)
  expect_null(seen$query$relevanceLanguage)

  yt_search("x", relevance_language = "hi")
  expect_equal(seen$query$relevanceLanguage, "hi")
})

test_that("yt_search rejects video-only filters for other resource types", {
  expect_error(
    yt_search("x", type = "channel", event_type = "live"),
    class = "tuber_conflicting_parameters"
  )
  expect_error(
    yt_search(
      "x", type = "playlist",
      location = "(37.42,-122.08)", location_radius = "5km"
    ),
    class = "tuber_conflicting_parameters"
  )
})

# Channels -------------------------------------------------------------------

test_that("get_channel_details no longer offers the retired category filter", {
  expect_false("category_id" %in% names(formals(get_channel_details)))
})

test_that("list_channel_videos reports why a channel could not be resolved", {
  local_mocked_bindings(tuber_GET = function(...) list(items = list()))

  expect_error(
    list_channel_videos("some-handle"),
    class = "tuber_channel_not_found"
  )
})

# Uploads and quota ----------------------------------------------------------

test_that("max_tries counts failed chunks, not the status checks between them", {
  path <- withr::local_tempfile()
  writeBin(as.raw(rep(1, 1024)), path)
  seen <- new.env(parent = emptyenv())
  seen$chunks <- 0L

  local_mocked_bindings(
    yt_access_token = function() "fake-token",
    upload_retry_wait = function(attempt) invisible(NULL)
  )
  httr2::local_mocked_responses(function(req) {
    range <- httr2::req_get_headers(req, "reveal")$`Content-Range`
    if (startsWith(range, "bytes */")) {
      return(httr2::response(308L))
    }
    seen$chunks <- seen$chunks + 1L
    httr2::response(503L)
  })

  expect_error(
    tuber:::tuber_upload_file(
      "https://upload.example/s", path, "video/mp4", max_tries = 5
    ),
    class = "tuber_upload_interrupted"
  )
  expect_equal(seen$chunks, 5L)
})

test_that("liveChatMessages.list is charged the five units Google lists", {
  expect_equal(tuber:::quota_cost("liveChatMessages", "list")$cost, 5L)
})

# Internal calls that dots used to hide ---------------------------------------

# Mocked at the HTTP layer, so the package's own wrappers are called with
# their real signatures.
channel_api <- function(path, query, ...) {
  switch(path,
    channels = list(items = lapply(strsplit(query$id, ",")[[1]], function(id) {
      list(
        id = id,
        snippet = list(title = paste("Channel", id)),
        statistics = list(viewCount = "100", subscriberCount = "10", videoCount = "2"),
        contentDetails = list(relatedPlaylists = list(uploads = "UUx"))
      )
    })),
    playlistItems = list(items = list(
      list(id = "i1", snippet = list(resourceId = list(videoId = "v1")))
    )),
    videos = list(
      kind = "youtube#videoListResponse",
      etag = "e",
      items = list(list(
        kind = "youtube#video",
        etag = "e1",
        id = "v1",
        snippet = list(title = "Video 1"),
        statistics = list(viewCount = "7", likeCount = "1", commentCount = "0")
      ))
    )
  )
}

test_that("compare_channels calls get_channel_details with arguments it accepts", {
  local_mocked_bindings(tuber_GET = channel_api)

  comparison <- suppressMessages(compare_channels(c("UC1", "UC2")))

  expect_equal(nrow(comparison$comparison), 2)
})

test_that("analyze_channel calls get_channel_details with arguments it accepts", {
  local_mocked_bindings(tuber_GET = channel_api)

  analysis <- suppressMessages(analyze_channel("UC1"))

  expect_equal(analysis$performance_metrics$videos_analyzed, 1)
})

# Scope: only what needs the YouTube API --------------------------------------

test_that("generic utilities are not part of the public API", {
  exports <- getNamespaceExports("tuber")

  expect_false(any(c("%>%", "search_short_videos", "with_retry") %in% exports))
})

test_that("API keys are stored and read as given, with no encryption layer", {
  expect_null(formals(yt_get_key))
  expect_equal(names(formals(yt_set_key)), "key")

  withr::local_envvar(YOUTUBE_KEY = NA)
  suppressMessages(yt_set_key("plain-key"))
  expect_equal(suppressMessages(yt_get_key()), "plain-key")
})

test_that("analyze_trends reports measured quantities, ordered by total views", {
  local_mocked_bindings(
    yt_search = function(term, ...) {
      data.frame(
        video_id = paste0(term, 1:2),
        title = "t",
        channel_title = "c",
        published_at = "2024-01-01T00:00:00Z"
      )
    },
    get_video_details = function(video_ids, ...) {
      views <- if (startsWith(video_ids[[1]], "small")) c("1", "2") else c("100", "200")
      data.frame(
        id = video_ids,
        statistics_viewCount = views,
        statistics_likeCount = c("1", "1"),
        statistics_commentCount = c("0", "0")
      )
    }
  )

  trends <- suppressMessages(analyze_trends(c("small", "big")))

  expect_false("trending_score" %in% names(trends$trend_summary))
  expect_equal(trends$trend_summary$search_term, c("big", "small"))
  expect_equal(trends$trend_summary$total_views, c(300, 3))
})

# Findings from the independent release review --------------------------------

quota_exhausted_response <- function(req) {
  json_response(
    list(error = list(
      code = 403,
      message = "The request cannot be completed because you have exceeded your quota.",
      errors = list(list(reason = "quotaExceeded"))
    )),
    status = 403L
  )
}

test_that("upload arguments are checked before a session opens or quota is charged", {
  local_fake_token()
  video <- withr::local_tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video)
  empty <- withr::local_tempfile(fileext = ".vtt")
  file.create(empty)
  requests <- 0L
  httr2::local_mocked_responses(function(req) {
    requests <<- requests + 1L
    httr2::response(200L, headers = list(location = "https://upload.example/s"))
  })
  yt_reset_quota()

  expect_error(
    upload_video(video, snippet = list(title = "t"), chunk_size = 1000),
    class = "tuber_invalid_chunk_size"
  )
  expect_error(
    upload_video(video, snippet = list(title = "t"), max_tries = 0),
    "max_tries"
  )
  expect_error(
    upload_caption(empty, video_id = "abcdefghijk", caption_name = "English"),
    class = "tuber_empty_file"
  )
  expect_equal(requests, 0L)
  expect_equal(sum(yt_get_quota_usage()$quota_used), 0)
})

test_that("a quota-exhausted error carries reason and status like any HTTP error", {
  withr::local_envvar(YOUTUBE_KEY = "fake-key")
  httr2::local_mocked_responses(quota_exhausted_response)

  err <- expect_error(
    tuber:::tuber_GET("videos", list(part = "id"), auth = "key"),
    class = "tuber_quota_exhausted"
  )
  expect_s3_class(err, "tuber_http_error")
  expect_equal(err$reason, "quotaExceeded")
  expect_equal(err$status_code, 403)
})

test_that("get_all_channel_video_stats lets the underlying error class through", {
  withr::local_envvar(YOUTUBE_KEY = "fake-key")
  httr2::local_mocked_responses(quota_exhausted_response)

  expect_error(
    get_all_channel_video_stats(channel_id = "UCxxxxxxxxxxxxxxxxxxxxxx"),
    class = "tuber_quota_exhausted"
  )
})

test_that("list_comments returns every comment asked for by ID", {
  ids <- paste0("c", 1:120)
  local_mocked_bindings(tuber_GET = function(path, query, ...) {
    list(items = lapply(ids, function(id) list(id = id, snippet = list())))
  })

  expect_equal(list_comments(comment_ids = ids)$comment_id, ids)
})

test_that("text symbols Unicode does not class as emoji are left alone", {
  rating <- "Rated \u2605\u2605\u2605\u2606\u2606 \u2610 todo"

  expect_false(has_emoji(rating))
  expect_equal(remove_emojis(rating), rating)
  expect_true(has_emoji("\u2600"))
  expect_equal(count_emojis("\U0001FAE8"), 1L)
})

test_that("making a scheduled video public drops its publish time", {
  local_fake_token()
  seen <- new.env(parent = emptyenv())
  httr2::local_mocked_responses(function(req) {
    if (!is.null(req$body)) {
      seen$json <- request_json(req)
      return(json_response(list(id = "abcdefghijk")))
    }
    json_response(list(items = list(list(
      id = "abcdefghijk",
      status = list(
        privacyStatus = "private",
        publishAt = "2030-01-01T00:00:00Z",
        embeddable = TRUE
      )
    ))))
  })

  update_video_metadata("abcdefghijk", privacy_status = "public")
  expect_false(grepl("publishAt", seen$json, fixed = TRUE))

  update_video_metadata("abcdefghijk", embeddable = FALSE)
  expect_match(seen$json, '"publishAt":"2030-01-01T00:00:00Z"', fixed = TRUE)
})

# r-canon implementation guidance: conditions --------------------------------

membership_refused <- function(req) {
  json_response(
    list(error = list(
      code = 403,
      message = "The request is not properly authorized to retrieve members.",
      errors = list(list(reason = "channelMembershipsNotEnabled"))
    )),
    status = 403L
  )
}

test_that("a refused members request is recognized by status, not by wording", {
  local_fake_token()
  httr2::local_mocked_responses(membership_refused)

  err <- expect_error(list_channel_members(), class = "tuber_members_forbidden")
  expect_s3_class(err$parent, "tuber_http_error")
  expect_equal(err$parent$reason, "channelMembershipsNotEnabled")
})

test_that("a refused Super Chat request is recognized by status, not by wording", {
  local_fake_token()
  httr2::local_mocked_responses(membership_refused)

  err <- expect_error(list_super_chat_events(), class = "tuber_super_chat_forbidden")
  expect_s3_class(err$parent, "tuber_http_error")
})

test_that("quota exhaustion is not relabelled as a membership problem", {
  local_fake_token()
  httr2::local_mocked_responses(quota_exhausted_response)

  expect_error(list_channel_members(), class = "tuber_quota_exhausted")
  expect_error(list_super_chat_events(), class = "tuber_quota_exhausted")
})

test_that("validation errors name the function the user called", {
  local_fake_token()
  video <- withr::local_tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video)

  err <- expect_error(
    upload_video(video, snippet = list(title = "t"), chunk_size = 1000),
    class = "tuber_invalid_chunk_size"
  )
  expect_equal(rlang::call_name(err$call), "upload_video")

  err <- expect_error(
    yt_search("x", published_after = "yesterday"),
    class = "tuber_invalid_date_format"
  )
  expect_equal(rlang::call_name(err$call), "yt_search")
})

test_that("a failed token refresh keeps the underlying error as its parent", {
  withr::local_options(
    google_token = httr2::oauth_token(
      "stale", refresh_token = "r", expires_in = -1000
    ),
    tuber.oauth_client = tuber:::.oauth_client("id", "secret")
  )
  local_mocked_bindings(oauth_flow_refresh = function(...) stop("invalid_grant"))

  err <- expect_error(
    tuber:::yt_access_token(),
    class = "tuber_token_refresh_failed"
  )
  expect_equal(conditionMessage(err$parent), "invalid_grant")
})

test_that("upload_video matches privacy and license values exactly", {
  local_fake_token()
  video <- withr::local_tempfile(fileext = ".mp4")
  writeBin(as.raw(1:10), video)
  requests <- 0L
  httr2::local_mocked_responses(function(req) {
    requests <<- requests + 1L
    httr2::response(200L, headers = list(location = "https://upload.example/s"))
  })

  expect_error(
    upload_video(video, status = list(privacyStatus = "priv")),
    "privacyStatus"
  )
  expect_error(
    upload_video(video, status = list(privacyStatus = "private", license = "you")),
    "license"
  )
  expect_equal(requests, 0L)
})
