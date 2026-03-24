# Tests for write/mutation operations using mock-based testing
# These tests ensure parameter validation and error handling work correctly
# without making actual API calls that could modify data.

context("Write Operations Tests")

# ============================================================================
# Mock Functions for POST/PUT/DELETE Operations
# ============================================================================

mock_tuber_POST_json <- function(path, query, body, ...) {
  if (path == "playlists") {
    mock_create_playlist_response(body)
  } else if (path == "playlistItems") {
    mock_add_video_response(body)
  } else {
    list(error = list(code = 404, message = "Unknown endpoint"))
  }
}

mock_tuber_DELETE <- function(path, query, ...) {
  id <- query$id
  if (is.null(id) || nchar(id) == 0) {
    list(error = list(code = 400, message = "Missing required parameter: id"))
  } else if (path == "comments") {
    mock_delete_response()
  } else if (path == "videos") {
    mock_delete_response()
  } else if (path == "playlists") {
    mock_delete_response()
  } else if (path == "playlistItems") {
    mock_delete_response()
  } else {
    list(error = list(code = 404, message = "Unknown endpoint"))
  }
}

mock_tuber_PUT <- function(path, query, body, ...) {
  if (path == "videos") {
    mock_update_video_response(body)
  } else if (path == "playlists") {
    mock_update_playlist_response(body)
  } else {
    list(error = list(code = 404, message = "Unknown endpoint"))
  }
}

mock_create_playlist_response <- function(body) {
  list(
    kind = "youtube#playlist",
    etag = "mock_etag",
    id = "PLmock123456789",
    snippet = list(
      publishedAt = "2024-01-01T00:00:00Z",
      channelId = "UCmockChannel",
      title = body$snippet$title,
      description = body$snippet$description %||% "",
      thumbnails = list(default = list(url = "https://example.com/thumb.jpg"))
    ),
    status = list(
      privacyStatus = body$status$privacyStatus %||% "public"
    )
  )
}

mock_add_video_response <- function(body) {
  list(
    kind = "youtube#playlistItem",
    etag = "mock_etag",
    id = "PLImock123456789",
    snippet = list(
      publishedAt = "2024-01-01T00:00:00Z",
      channelId = "UCmockChannel",
      title = "Mock Video Title",
      playlistId = body$snippet$playlistId,
      position = body$snippet$position %||% 0,
      resourceId = body$snippet$resourceId
    )
  )
}

mock_delete_response <- function() {
  list()
}

mock_update_video_response <- function(body) {
  list(
    kind = "youtube#video",
    etag = "mock_etag",
    id = body$id,
    snippet = list(
      title = body$snippet$title,
      description = body$snippet$description,
      categoryId = body$snippet$categoryId
    ),
    status = list(
      privacyStatus = body$status$privacyStatus,
      selfDeclaredMadeForKids = body$status$selfDeclaredMadeForKids
    )
  )
}

mock_update_playlist_response <- function(body) {
  list(
    kind = "youtube#playlist",
    etag = "mock_etag",
    id = body$id,
    snippet = list(
      title = body$snippet$title
    )
  )
}

# ============================================================================
# create_playlist Tests
# ============================================================================

test_that("create_playlist validates title parameter", {
  expect_error(create_playlist(title = NULL), "title")
  expect_error(create_playlist(title = ""), "title")
  expect_error(create_playlist(title = 123), "title")
  expect_error(create_playlist(title = c("a", "b")), "title")
})

test_that("create_playlist validates status parameter", {
  expect_error(
    create_playlist(title = "Test", status = "invalid"),
    "status"
  )
})

test_that("create_playlist accepts valid status values", {
  with_mocked_bindings(
    tuber_POST_json = mock_tuber_POST_json,
    yt_check_token = function() invisible(NULL),
    {
      result <- create_playlist(title = "Test", status = "public")
      expect_equal(result$status$privacyStatus, "public")

      result <- create_playlist(title = "Test", status = "private")
      expect_equal(result$status$privacyStatus, "private")

      result <- create_playlist(title = "Test", status = "unlisted")
      expect_equal(result$status$privacyStatus, "unlisted")
    }
  )
})

test_that("create_playlist returns playlist ID on success", {
  with_mocked_bindings(
    tuber_POST_json = mock_tuber_POST_json,
    yt_check_token = function() invisible(NULL),
    {
      result <- create_playlist(title = "My Test Playlist", description = "Test description")
      expect_true(!is.null(result$id))
      expect_equal(result$snippet$title, "My Test Playlist")
      expect_equal(result$snippet$description, "Test description")
    }
  )
})

# ============================================================================
# add_video_to_playlist Tests
# ============================================================================

test_that("add_video_to_playlist validates playlist_id parameter", {
  expect_error(add_video_to_playlist(playlist_id = NULL, video_id = "abc"), "playlist_id")
  expect_error(add_video_to_playlist(playlist_id = "", video_id = "abc"), "playlist_id")
  expect_error(add_video_to_playlist(playlist_id = 123, video_id = "abc"), "playlist_id")
})

test_that("add_video_to_playlist validates video_id parameter", {
  expect_error(add_video_to_playlist(playlist_id = "abc", video_id = NULL), "video_id")
  expect_error(add_video_to_playlist(playlist_id = "abc", video_id = ""), "video_id")
  expect_error(add_video_to_playlist(playlist_id = "abc", video_id = 123), "video_id")
})

test_that("add_video_to_playlist validates position parameter", {
  expect_error(
    add_video_to_playlist(playlist_id = "abc", video_id = "xyz", position = -1),
    "position"
  )
  expect_error(
    add_video_to_playlist(playlist_id = "abc", video_id = "xyz", position = "first"),
    "position"
  )
})

test_that("add_video_to_playlist returns response on success", {
  with_mocked_bindings(
    tuber_POST_json = mock_tuber_POST_json,
    yt_check_token = function() invisible(NULL),
    {
      result <- add_video_to_playlist(playlist_id = "PLtest123", video_id = "dQw4w9WgXcQ")
      expect_true(!is.null(result$id))
      expect_equal(result$snippet$playlistId, "PLtest123")
      expect_equal(result$snippet$resourceId$videoId, "dQw4w9WgXcQ")
    }
  )
})

test_that("add_video_to_playlist respects position parameter", {
  with_mocked_bindings(
    tuber_POST_json = mock_tuber_POST_json,
    yt_check_token = function() invisible(NULL),
    {
      result <- add_video_to_playlist(playlist_id = "PLtest123", video_id = "dQw4w9WgXcQ", position = 5)
      expect_equal(result$snippet$position, 5)
    }
  )
})

# ============================================================================
# delete_comments Tests
# ============================================================================

test_that("delete_comments validates id parameter", {
  expect_error(delete_comments(id = NULL), "id")
  expect_error(delete_comments(id = ""), "id")
  expect_error(delete_comments(id = 123), "id")
  expect_error(delete_comments(id = c("a", "b")), "id")
})

test_that("delete_comments calls API correctly", {
  with_mocked_bindings(
    tuber_DELETE = mock_tuber_DELETE,
    yt_check_token = function() invisible(NULL),
    {
      result <- delete_comments(id = "comment123")
      expect_type(result, "list")
    }
  )
})

# ============================================================================
# delete_videos Tests
# ============================================================================

test_that("delete_videos validates id parameter", {
  expect_error(delete_videos(id = NULL), "id")
  expect_error(delete_videos(id = ""), "id")
  expect_error(delete_videos(id = 123), "id")
  expect_error(delete_videos(id = c("a", "b")), "id")
})

test_that("delete_videos calls API correctly", {
  with_mocked_bindings(
    tuber_DELETE = mock_tuber_DELETE,
    yt_check_token = function() invisible(NULL),
    {
      result <- delete_videos(id = "video123")
      expect_type(result, "list")
    }
  )
})

# ============================================================================
# delete_playlists Tests
# ============================================================================

test_that("delete_playlists validates id parameter", {
  expect_error(delete_playlists(id = NULL), "id")
  expect_error(delete_playlists(id = ""), "id")
  expect_error(delete_playlists(id = 123), "id")
  expect_error(delete_playlists(id = c("a", "b")), "id")
})

test_that("delete_playlists calls API correctly", {
  with_mocked_bindings(
    tuber_DELETE = mock_tuber_DELETE,
    yt_check_token = function() invisible(NULL),
    {
      result <- delete_playlists(id = "playlist123")
      expect_type(result, "list")
    }
  )
})

# ============================================================================
# delete_playlist_items Tests
# ============================================================================

test_that("delete_playlist_items validates id parameter", {
  expect_error(delete_playlist_items(id = NULL), "id")
  expect_error(delete_playlist_items(id = ""), "id")
  expect_error(delete_playlist_items(id = 123), "id")
  expect_error(delete_playlist_items(id = c("a", "b")), "id")
})

test_that("delete_playlist_items calls API correctly", {
  with_mocked_bindings(
    tuber_DELETE = mock_tuber_DELETE,
    yt_check_token = function() invisible(NULL),
    {
      result <- delete_playlist_items(id = "playlistItem123")
      expect_type(result, "list")
    }
  )
})

# ============================================================================
# update_video_metadata Tests
# ============================================================================

test_that("update_video_metadata validates video_id parameter", {
  expect_error(
    update_video_metadata(
      video_id = NULL, title = "Test", category_id = "24",
      description = "Test", privacy_status = "public", made_for_kids = FALSE
    ),
    "video_id"
  )
  expect_error(
    update_video_metadata(
      video_id = "", title = "Test", category_id = "24",
      description = "Test", privacy_status = "public", made_for_kids = FALSE
    ),
    "video_id"
  )
})

test_that("update_video_metadata validates title parameter", {
  expect_error(
    update_video_metadata(
      video_id = "abc", title = NULL, category_id = "24",
      description = "Test", privacy_status = "public", made_for_kids = FALSE
    ),
    "title"
  )
  expect_error(
    update_video_metadata(
      video_id = "abc", title = "", category_id = "24",
      description = "Test", privacy_status = "public", made_for_kids = FALSE
    ),
    "title"
  )
})

test_that("update_video_metadata validates privacy_status parameter", {
  expect_error(
    update_video_metadata(
      video_id = "abc", title = "Test", category_id = "24",
      description = "Test", privacy_status = "invalid", made_for_kids = FALSE
    ),
    "privacy_status"
  )
})

test_that("update_video_metadata validates made_for_kids parameter", {
  expect_error(
    update_video_metadata(
      video_id = "abc", title = "Test", category_id = "24",
      description = "Test", privacy_status = "public", made_for_kids = "yes"
    ),
    "made_for_kids"
  )
})

test_that("update_video_metadata returns response on success", {
  with_mocked_bindings(
    tuber_PUT = mock_tuber_PUT,
    yt_check_token = function() invisible(NULL),
    yt_check_key = function() invisible(NULL),
    {
      result <- update_video_metadata(
        video_id = "video123",
        title = "New Title",
        category_id = "24",
        description = "New Description",
        privacy_status = "public",
        made_for_kids = FALSE
      )
      expect_equal(result$id, "video123")
      expect_equal(result$snippet$title, "New Title")
      expect_equal(result$snippet$description, "New Description")
      expect_equal(result$status$privacyStatus, "public")
    }
  )
})

# ============================================================================
# change_playlist_title Tests
# ============================================================================

test_that("change_playlist_title validates playlist_id parameter", {
  expect_error(change_playlist_title(playlist_id = NULL, new_title = "Test"), "playlist_id")
  expect_error(change_playlist_title(playlist_id = "", new_title = "Test"), "playlist_id")
  expect_error(change_playlist_title(playlist_id = 123, new_title = "Test"), "playlist_id")
})

test_that("change_playlist_title validates new_title parameter", {
  expect_error(change_playlist_title(playlist_id = "abc", new_title = NULL), "new_title")
  expect_error(change_playlist_title(playlist_id = "abc", new_title = ""), "new_title")
  expect_error(change_playlist_title(playlist_id = "abc", new_title = 123), "new_title")
})

test_that("change_playlist_title returns response on success", {
  with_mocked_bindings(
    tuber_PUT = mock_tuber_PUT,
    yt_check_token = function() invisible(NULL),
    yt_check_key = function() invisible(NULL),
    {
      result <- change_playlist_title(playlist_id = "playlist123", new_title = "Updated Title")
      expect_equal(result$id, "playlist123")
      expect_equal(result$snippet$title, "Updated Title")
    }
  )
})

# ============================================================================
# upload_video Tests (validation only, no actual upload)
# ============================================================================

test_that("upload_video validates file parameter", {
  expect_error(upload_video(file = NULL), "file")
  expect_error(upload_video(file = ""), "file")
  expect_error(upload_video(file = 123), "file")
})

test_that("upload_video checks file exists", {
  expect_error(
    upload_video(file = "/nonexistent/path/to/video.mp4"),
    "File does not exist"
  )
})

test_that("upload_video validates open_url parameter", {
  temp_file <- tempfile(fileext = ".mp4")
  writeLines("fake video content", temp_file)
  on.exit(unlink(temp_file))

  expect_error(
    upload_video(file = temp_file, open_url = "yes"),
    "open_url"
  )
  expect_error(
    upload_video(file = temp_file, open_url = 123),
    "open_url"
  )
})

test_that("upload_video validates snippet parameter", {
  temp_file <- tempfile(fileext = ".mp4")
  writeLines("fake video content", temp_file)
  on.exit(unlink(temp_file))

  expect_error(
    upload_video(file = temp_file, snippet = "not a list"),
    "snippet"
  )
})

test_that("upload_video validates status parameter", {
  temp_file <- tempfile(fileext = ".mp4")
  writeLines("fake video content", temp_file)
  on.exit(unlink(temp_file))

  expect_error(
    upload_video(file = temp_file, status = "not a list"),
    "status"
  )
})

# ============================================================================
# Error Handling Tests
# ============================================================================

test_that("write operations handle API errors gracefully", {
  mock_error_POST <- function(path, query, body, ...) {
    list(
      error = list(
        code = 403,
        message = "The playlist cannot be modified.",
        errors = list(list(
          reason = "playlistOperationUnsupported"
        ))
      )
    )
  }

  with_mocked_bindings(
    tuber_POST_json = mock_error_POST,
    yt_check_token = function() invisible(NULL),
    {
      result <- create_playlist(title = "Test")
      expect_true(!is.null(result$error))
      expect_equal(result$error$code, 403)
    }
  )
})

test_that("write operations handle quota exceeded errors", {
  mock_quota_error <- function(path, query, ...) {
    list(
      error = list(
        code = 403,
        message = "The request cannot be completed because you have exceeded your quota.",
        errors = list(list(
          reason = "quotaExceeded"
        ))
      )
    )
  }

  with_mocked_bindings(
    tuber_DELETE = mock_quota_error,
    yt_check_token = function() invisible(NULL),
    {
      result <- delete_comments(id = "comment123")
      expect_true(!is.null(result$error))
      expect_equal(result$error$errors[[1]]$reason, "quotaExceeded")
    }
  )
})

test_that("write operations handle not found errors", {
  mock_not_found_error <- function(path, query, ...) {
    list(
      error = list(
        code = 404,
        message = "The video identified by the id parameter could not be found.",
        errors = list(list(
          reason = "videoNotFound"
        ))
      )
    )
  }

  with_mocked_bindings(
    tuber_DELETE = mock_not_found_error,
    yt_check_token = function() invisible(NULL),
    {
      result <- delete_videos(id = "nonexistent")
      expect_true(!is.null(result$error))
      expect_equal(result$error$code, 404)
    }
  )
})
