# Fixtures ------------------------------------------------------------------

local_upload_file <- function(size, env = parent.frame()) {
  path <- withr::local_tempfile(.local_envir = env)
  writeBin(as.raw(rep(0:255, length.out = size)), path)
  path
}

local_upload_mocks <- function(env = parent.frame()) {
  testthat::local_mocked_bindings(
    yt_access_token = function() "fake-token",
    upload_retry_wait = function(attempt) invisible(NULL),
    .package = "tuber",
    .env = env
  )
}

content_range <- function(req) {
  httr2::req_get_headers(req, "reveal")$`Content-Range`
}

# Chunking ------------------------------------------------------------------

test_that("tuber_upload_file sends the whole file as sequential chunks", {
  chunk <- 256 * 1024
  path <- local_upload_file(2 * chunk + 100)
  total <- file.size(path)

  seen <- new.env(parent = emptyenv())
  seen$ranges <- character()
  seen$bytes <- raw()

  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$ranges <- c(seen$ranges, content_range(req))
    seen$bytes <- c(seen$bytes, req$body$data)
    received <- length(seen$bytes)
    if (received < total) {
      httr2::response(
        308L,
        headers = list(range = sprintf("bytes=0-%d", received - 1))
      )
    } else {
      httr2::response_json(201L, body = list(id = "abcdefghijk"))
    }
  })

  resp <- tuber:::tuber_upload_file(
    "https://upload.example/session",
    path,
    "video/mp4",
    chunk_size = chunk
  )

  expect_equal(seen$ranges, c(
    sprintf("bytes 0-%d/%d", chunk - 1, total),
    sprintf("bytes %d-%d/%d", chunk, 2 * chunk - 1, total),
    sprintf("bytes %d-%d/%d", 2 * chunk, total - 1, total)
  ))
  expect_equal(seen$bytes, readBin(path, "raw", n = total))
  expect_equal(httr2::resp_status(resp), 201L)
})

test_that("tuber_upload_file sends a small file in a single chunk", {
  path <- local_upload_file(10)

  seen <- new.env(parent = emptyenv())
  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$n <- (seen$n %||% 0) + 1
    seen$range <- content_range(req)
    httr2::response_json(201L, body = list(id = "abcdefghijk"))
  })

  tuber:::tuber_upload_file("https://upload.example/s", path, "video/mp4")

  expect_equal(seen$n, 1)
  expect_equal(seen$range, "bytes 0-9/10")
})

# Resumption ----------------------------------------------------------------

test_that("tuber_upload_file resumes from the offset the server reports", {
  chunk <- 256 * 1024
  path <- local_upload_file(2 * chunk)
  total <- file.size(path)

  seen <- new.env(parent = emptyenv())
  seen$ranges <- character()
  seen$call <- 0

  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$call <- seen$call + 1
    seen$ranges <- c(seen$ranges, content_range(req))
    # Call 1 sends bytes 0-262143 and dies mid-flight; the server kept the
    # first 1000 bytes. Call 2 must be the status query, and call 3 must
    # restart from byte 1000 rather than from byte 0 or byte 262144.
    if (seen$call == 1) {
      rlang::abort("Timeout was reached", class = "httr2_failure")
    }
    if (seen$call == 2) {
      return(httr2::response(308L, headers = list(range = "bytes=0-999")))
    }
    if (seen$call == 3) {
      return(httr2::response(
        308L,
        headers = list(range = sprintf("bytes=0-%d", 1000 + chunk - 1))
      ))
    }
    httr2::response_json(201L, body = list(id = "abcdefghijk"))
  })

  resp <- tuber:::tuber_upload_file(
    "https://upload.example/session",
    path,
    "video/mp4",
    chunk_size = chunk
  )

  expect_equal(seen$ranges, c(
    sprintf("bytes 0-%d/%d", chunk - 1, total),
    sprintf("bytes */%d", total),
    sprintf("bytes 1000-%d/%d", 1000 + chunk - 1, total),
    sprintf("bytes %d-%d/%d", 1000 + chunk, total - 1, total)
  ))
  expect_equal(httr2::resp_status(resp), 201L)
})

test_that("tuber_upload_file re-syncs after a 5xx instead of resending blindly", {
  chunk <- 256 * 1024
  path <- local_upload_file(2 * chunk)
  total <- file.size(path)

  seen <- new.env(parent = emptyenv())
  seen$ranges <- character()
  seen$call <- 0

  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$call <- seen$call + 1
    seen$ranges <- c(seen$ranges, content_range(req))
    if (seen$call == 1) {
      return(httr2::response(503L))
    }
    if (seen$call == 2) {
      return(httr2::response(
        308L,
        headers = list(range = sprintf("bytes=0-%d", chunk - 1))
      ))
    }
    httr2::response_json(201L, body = list(id = "abcdefghijk"))
  })

  tuber:::tuber_upload_file(
    "https://upload.example/session",
    path,
    "video/mp4",
    chunk_size = chunk
  )

  expect_equal(seen$ranges[2], sprintf("bytes */%d", total))
  expect_equal(
    seen$ranges[3],
    sprintf("bytes %d-%d/%d", chunk, total - 1, total)
  )
})

test_that("tuber_upload_file restarts at zero when the status query has no Range", {
  path <- local_upload_file(1000)

  seen <- new.env(parent = emptyenv())
  seen$ranges <- character()
  seen$call <- 0

  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$call <- seen$call + 1
    seen$ranges <- c(seen$ranges, content_range(req))
    if (seen$call == 1) {
      return(httr2::response(500L))
    }
    if (seen$call == 2) {
      # No Range header: YouTube received nothing at all.
      return(httr2::response(308L))
    }
    httr2::response_json(201L, body = list(id = "abcdefghijk"))
  })

  tuber:::tuber_upload_file("https://upload.example/s", path, "video/mp4")

  expect_equal(seen$ranges[3], "bytes 0-999/1000")
})

test_that("tuber_upload_file returns the 200 a status query reports", {
  path <- local_upload_file(1000)

  seen <- new.env(parent = emptyenv())
  seen$call <- 0

  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$call <- seen$call + 1
    if (seen$call == 1) {
      rlang::abort("Connection reset by peer", class = "httr2_failure")
    }
    # The bytes did land; the response to the original PUT was what got lost.
    httr2::response_json(200L, body = list(id = "abcdefghijk"))
  })

  resp <- tuber:::tuber_upload_file("https://upload.example/s", path, "video/mp4")

  expect_equal(httr2::resp_status(resp), 200L)
  expect_equal(seen$call, 2)
})

# Giving up -----------------------------------------------------------------

test_that("tuber_upload_file stops after max_tries consecutive failures", {
  path <- local_upload_file(1000)

  seen <- new.env(parent = emptyenv())
  seen$call <- 0

  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$call <- seen$call + 1
    httr2::response(503L)
  })

  expect_error(
    tuber:::tuber_upload_file(
      "https://upload.example/s",
      path,
      "video/mp4",
      max_tries = 3
    ),
    class = "tuber_upload_interrupted"
  )
  expect_equal(seen$call, 3)
})

test_that("tuber_upload_file stops when the server never advances", {
  chunk <- 256 * 1024
  path <- local_upload_file(2 * chunk)

  seen <- new.env(parent = emptyenv())
  seen$call <- 0

  local_upload_mocks()
  httr2::local_mocked_responses(function(req) {
    seen$call <- seen$call + 1
    # Always 308 at byte 0: a well-formed response that makes no progress.
    httr2::response(308L)
  })

  expect_error(
    tuber:::tuber_upload_file(
      "https://upload.example/s",
      path,
      "video/mp4",
      chunk_size = chunk,
      max_tries = 4
    ),
    class = "tuber_upload_interrupted"
  )
  expect_lt(seen$call, 20)
})

test_that("tuber_upload_file reports an expired session URL", {
  path <- local_upload_file(1000)

  local_upload_mocks()
  httr2::local_mocked_responses(list(httr2::response(404L)))

  expect_error(
    tuber:::tuber_upload_file("https://upload.example/s", path, "video/mp4"),
    class = "tuber_upload_session_expired"
  )
})

test_that("tuber_upload_file returns other error responses for the caller to check", {
  path <- local_upload_file(1000)

  local_upload_mocks()
  httr2::local_mocked_responses(list(httr2::response(400L)))

  resp <- tuber:::tuber_upload_file("https://upload.example/s", path, "video/mp4")
  expect_equal(httr2::resp_status(resp), 400L)
})

# Validation ----------------------------------------------------------------

test_that("tuber_upload_file requires a 256 KB-aligned chunk size", {
  path <- local_upload_file(1000)
  local_upload_mocks()

  expect_error(
    tuber:::tuber_upload_file(
      "https://upload.example/s", path, "video/mp4",
      chunk_size = 300 * 1024
    ),
    class = "tuber_invalid_chunk_size"
  )
  expect_error(
    tuber:::tuber_upload_file(
      "https://upload.example/s", path, "video/mp4",
      chunk_size = 100 * 1024
    ),
    class = "tuber_invalid_chunk_size"
  )
})

test_that("tuber_upload_file rejects an empty file", {
  path <- withr::local_tempfile()
  file.create(path)
  local_upload_mocks()

  expect_error(
    tuber:::tuber_upload_file("https://upload.example/s", path, "video/mp4"),
    class = "tuber_empty_file"
  )
})

# Public surface ------------------------------------------------------------

test_that("upload_video resumes an interrupted upload", {
  chunk <- 256 * 1024
  path <- local_upload_file(2 * chunk)
  total <- file.size(path)

  seen <- new.env(parent = emptyenv())
  seen$ranges <- character()
  seen$call <- 0

  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(...) invisible(NULL),
    upload_retry_wait = function(attempt) invisible(NULL),
    .package = "tuber"
  )
  httr2::local_mocked_responses(function(req) {
    if (identical(req$method, "POST")) {
      return(httr2::response(
        200L,
        headers = list(location = "https://upload.example/session")
      ))
    }
    seen$call <- seen$call + 1
    seen$ranges <- c(seen$ranges, content_range(req))
    if (seen$call == 1) {
      rlang::abort("Timeout was reached", class = "httr2_failure")
    }
    if (seen$call == 2) {
      return(httr2::response(
        308L,
        headers = list(range = sprintf("bytes=0-%d", chunk - 1))
      ))
    }
    httr2::response_json(201L, body = list(id = "abcdefghijk"))
  })

  result <- upload_video(
    file = path,
    snippet = list(title = "A title"),
    chunk_size = chunk
  )

  expect_equal(seen$ranges, c(
    sprintf("bytes 0-%d/%d", chunk - 1, total),
    sprintf("bytes */%d", total),
    sprintf("bytes %d-%d/%d", chunk, total - 1, total)
  ))
  expect_equal(result$url, "https://www.youtube.com/watch?v=abcdefghijk")
})

test_that("upload_caption resumes an interrupted upload", {
  path <- local_upload_file(1000)

  seen <- new.env(parent = emptyenv())
  seen$call <- 0

  local_mocked_bindings(
    yt_check_token = function() invisible(NULL),
    yt_access_token = function() "fake-token",
    track_quota_usage = function(...) invisible(NULL),
    upload_retry_wait = function(attempt) invisible(NULL),
    .package = "tuber"
  )
  httr2::local_mocked_responses(function(req) {
    if (identical(req$method, "POST")) {
      return(httr2::response(
        200L,
        headers = list(location = "https://upload.example/caption")
      ))
    }
    seen$call <- seen$call + 1
    if (seen$call == 1) {
      return(httr2::response(503L))
    }
    if (seen$call == 2) {
      # Status query: YouTube kept nothing, so the file goes up again.
      return(httr2::response(308L))
    }
    httr2::response_json(201L, body = list(id = "caption-id"))
  })

  result <- upload_caption(
    file = path,
    video_id = "abcdefghijk",
    caption_name = "English"
  )

  expect_equal(seen$call, 3)
  expect_equal(result$content$id, "caption-id")
})

test_that("upload_video and upload_caption expose the chunk size", {
  expect_true("chunk_size" %in% names(formals(upload_video)))
  expect_true("chunk_size" %in% names(formals(upload_caption)))
})
