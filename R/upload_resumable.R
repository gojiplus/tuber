#' Minimum chunk size YouTube accepts, and the granularity every non-final
#' chunk must be a multiple of.
#' @keywords internal
#' @noRd
upload_chunk_unit <- 256L * 1024L

#' Wait before retrying an interrupted upload
#'
#' Split out from [tuber_upload_file()] so tests can replace the sleep.
#'
#' @param attempt Number of consecutive failures so far.
#' @return NULL, invisibly.
#' @keywords internal
#' @noRd
upload_retry_wait <- function(attempt) {
  invisible(Sys.sleep(min(2^(attempt - 1), 32)))
}

#' Build a PUT against a resumable session URL
#'
#' The session URL is a full URL YouTube chose, so these requests cannot go
#' through [tuber_request()]. Status codes come back as responses rather than
#' errors because 308 and 5xx both mean "keep going", not "stop".
#'
#' @param upload_url Session URL from [tuber_upload_session()].
#' @return An httr2 request.
#' @keywords internal
#' @noRd
upload_request <- function(upload_url) {
  request(upload_url) |>
    req_headers_redacted(Authorization = paste("Bearer", yt_access_token())) |>
    req_method("PUT") |>
    req_error(is_error = function(response) FALSE)
}

#' Send one chunk of the file
#'
#' @param con Open binary connection to the file.
#' @param offset First byte of this chunk, counting from zero.
#' @param total Size of the whole file in bytes.
#' @param chunk_size Maximum bytes to send in this request.
#' @param type MIME type of the file.
#' @inheritParams upload_request
#' @return An httr2 response.
#' @keywords internal
#' @noRd
upload_chunk_request <- function(upload_url, con, offset, total, chunk_size,
                                 type) {
  last <- min(offset + chunk_size, total) - 1
  seek(con, where = offset, origin = "start")
  bytes <- readBin(con, "raw", n = last - offset + 1)

  # %.0f rather than %d: file sizes are doubles, and a multi-gigabyte offset
  # would overflow an integer or print in scientific notation.
  upload_request(upload_url) |>
    req_headers(
      "Content-Range" = sprintf("bytes %.0f-%.0f/%.0f", offset, last, total)
    ) |>
    req_body_raw(bytes, type = type) |>
    req_perform()
}

#' Ask YouTube how much of the file it already has
#'
#' An empty PUT carrying `Content-Range: bytes *\/TOTAL`. YouTube answers 308
#' with a `Range` header when the upload is incomplete, or 2xx when the bytes
#' all arrived and only the response was lost.
#'
#' @inheritParams upload_chunk_request
#' @return An httr2 response.
#' @keywords internal
#' @noRd
upload_status_request <- function(upload_url, total) {
  upload_request(upload_url) |>
    req_headers("Content-Range" = sprintf("bytes */%.0f", total)) |>
    req_body_raw(raw(0)) |>
    req_perform()
}

#' Byte to resume from, given a 308 response
#'
#' `Range: bytes=0-999` means the first 1000 bytes arrived, so the next chunk
#' starts at byte 1000. No `Range` header means nothing arrived.
#'
#' @param resp An httr2 response.
#' @return The next byte offset.
#' @keywords internal
#' @noRd
resumed_offset <- function(resp) {
  range <- resp_header(resp, "range")
  if (is.null(range) || !nzchar(range)) {
    return(0)
  }
  last <- suppressWarnings(as.numeric(sub("^.*-", "", range)))
  if (is.na(last)) 0 else last + 1
}

#' Upload a file to a resumable session, resuming after interruptions
#'
#' The second half of [tuber_upload_session()]. The file goes up in chunks
#' tagged with `Content-Range`. When a chunk dies in flight or draws a 5xx,
#' this asks YouTube how many bytes it actually kept and continues from there
#' rather than restarting at byte zero, which is the whole point of the
#' resumable protocol on a slow or unreliable connection.
#'
#' Hand-rolled because no maintained R package implements this protocol against
#' an arbitrary session URL: gargle handles auth and request preparation only,
#' and googleCloudStorageR's resumable uploader is tied to the Cloud Storage
#' endpoints and the googleAuthR token stack. httr2's `req_retry()` cannot be
#' used either, since resuming means sending a *different* request (a shorter
#' chunk from a new offset), not repeating the failed one.
#'
#' @param upload_url Session URL from [tuber_upload_session()].
#' @param file Path to the file to upload.
#' @param type MIME type of \code{file}.
#' @param chunk_size Bytes per request. Must be a multiple of 256 KB.
#' @param max_tries Consecutive failed attempts to tolerate before giving up.
#' @return An httr2 response. The caller checks its status.
#' @references
#' <https://developers.google.com/youtube/v3/guides/using_resumable_upload_protocol>
#' @keywords internal
tuber_upload_file <- function(upload_url, file, type,
                              chunk_size = 8 * 1024^2,
                              max_tries = 5) {
  assert_numeric(
    chunk_size,
    len = 1, lower = 1, finite = TRUE,
    .var.name = "chunk_size"
  )
  assert_count(max_tries, positive = TRUE, .var.name = "max_tries")

  if (chunk_size %% upload_chunk_unit != 0) {
    abort(
      sprintf(
        "`chunk_size` must be a multiple of %d bytes (256 KB); got %.0f.",
        upload_chunk_unit, chunk_size
      ),
      chunk_size = chunk_size,
      class = "tuber_invalid_chunk_size"
    )
  }

  total <- file.size(file)
  if (total == 0) {
    abort(
      "Cannot upload an empty file",
      file_path = file,
      class = "tuber_empty_file"
    )
  }

  con <- file(file, "rb")
  on.exit(close(con), add = TRUE)

  offset <- 0
  confirmed <- 0
  failures <- 0

  repeat {
    # An NA offset means we no longer know how much YouTube has, so the next
    # request asks instead of guessing.
    resp <- tryCatch(
      if (is.na(offset)) {
        upload_status_request(upload_url, total)
      } else {
        upload_chunk_request(upload_url, con, offset, total, chunk_size, type)
      },
      httr2_failure = function(cnd) cnd
    )

    interrupted <- inherits(resp, "condition")
    status <- if (interrupted) NA_integer_ else resp_status(resp)

    if (!interrupted) {
      if (status %in% c(404L, 410L)) {
        abort(
          paste(
            "The resumable upload session has expired.",
            "Start the upload again."
          ),
          status_code = status,
          class = "tuber_upload_session_expired"
        )
      }
      if (status != 308L && status < 500L) {
        return(resp)
      }
    }

    # 308 is the only reply that says where the server actually is.
    resumed <- if (!interrupted && status == 308L) {
      resumed_offset(resp)
    } else {
      NA_real_
    }

    if (!is.na(resumed) && resumed > confirmed) {
      confirmed <- resumed
      offset <- resumed
      failures <- 0
      next
    }

    # Either the request failed, or it succeeded without moving the upload
    # forward. A stuck session has to time out rather than loop forever.
    failures <- failures + 1
    if (failures >= max_tries) {
      msg <- sprintf(
        "Upload of '%s' failed after %d attempts; %.0f of %.0f bytes sent.",
        basename(file), max_tries, confirmed, total
      )
      if (interrupted) {
        abort(
          msg,
          parent = resp,
          bytes_sent = confirmed, bytes_total = total,
          class = "tuber_upload_interrupted"
        )
      }
      abort(
        msg,
        status_code = status,
        bytes_sent = confirmed, bytes_total = total,
        class = "tuber_upload_interrupted"
      )
    }
    upload_retry_wait(failures)
    offset <- resumed
  }
}
