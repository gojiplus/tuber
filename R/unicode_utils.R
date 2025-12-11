#' Unicode and Text Processing Utilities
#'
#' Internal functions for consistent text and Unicode handling across tuber
#' @name unicode_utils
NULL

#' Safely Convert Text to UTF-8
#'
#' Ensures text fields are properly encoded in UTF-8
#'
#' @param text Character vector or list of text to convert
#' @param fallback_encoding Character. Encoding to assume if detection fails. Default: "latin1"
#' @return Character vector with UTF-8 encoding
#' @keywords internal
safe_utf8 <- function(text, fallback_encoding = "latin1") {

  # Modern validation using checkmate
  if (!is.null(text)) {
    assert(check_character(text), check_list(text), check_null(text),
           .var.name = "text")
  }
  assert_character(fallback_encoding, len = 1, .var.name = "fallback_encoding")

  if (is.null(text) || length(text) == 0) {
    return(character(0))
  }

  # Handle different input types
  if (is.list(text)) {
    return(lapply(text, safe_utf8, fallback_encoding = fallback_encoding))
  }

  if (!is.character(text)) {
    text <- as.character(text)
  }

  # Skip NA values
  if (any(is.na(text))) {
    result <- text
    valid_idx <- !is.na(text)
    if (any(valid_idx)) {
      result[valid_idx] <- safe_utf8(text[valid_idx], fallback_encoding)
    }
    return(result)
  }

  # Convert to UTF-8, handling different encodings gracefully
  tryCatch({
    # Try enc2utf8 first (fastest for already UTF-8 text)
    result <- enc2utf8(text)

    # Check for replacement characters that indicate encoding issues
    if (any(grepl("\uFFFD", result, fixed = TRUE))) {
      # Try with iconv for better encoding detection
      result <- iconv(text, from = fallback_encoding, to = "UTF-8", sub = "")

      # If still problematic, use byte-level approach
      if (any(is.na(result))) {
        result <- iconv(text, from = "UTF-8", to = "UTF-8", sub = "?")
      }
    }

    return(result)
  }, error = function(e) {
    warn("Unicode conversion failed for some text",
         error = e$message,
         fallback_encoding = fallback_encoding,
         class = "tuber_unicode_conversion_error")
    return(as.character(text))
  })
}

#' Clean and Normalize YouTube Text Data
#'
#' Applies consistent cleaning to YouTube text fields
#'
#' @param text Character vector of text to clean
#' @param remove_html Boolean. Remove HTML tags. Default: TRUE
#' @param normalize_whitespace Boolean. Normalize whitespace. Default: TRUE
#' @param max_length Integer. Maximum length (NULL for no limit). Default: NULL
#' @return Cleaned character vector
#' @keywords internal
clean_youtube_text <- function(text, remove_html = TRUE, normalize_whitespace = TRUE, max_length = NULL) {

  # Modern validation using checkmate
  if (!is.null(text)) {
    assert_character(text, .var.name = "text")
  }
  assert_flag(remove_html, .var.name = "remove_html")
  assert_flag(normalize_whitespace, .var.name = "normalize_whitespace")

  if (!is.null(max_length)) {
    assert_integerish(max_length, len = 1, lower = 1, .var.name = "max_length")
  }

  if (is.null(text) || length(text) == 0) {
    return(character(0))
  }

  # Convert to UTF-8 first
  text <- safe_utf8(text)

  # Remove HTML tags if requested
  if (remove_html) {
    text <- gsub("<[^>]+>", "", text)

    # Decode common HTML entities
    html_entities <- list(
      "&lt;" = "<", "&gt;" = ">", "&amp;" = "&", "&quot;" = "\"",
      "&apos;" = "'", "&#39;" = "'", "&nbsp;" = " "
    )

    for (entity in names(html_entities)) {
      text <- gsub(entity, html_entities[[entity]], text, fixed = TRUE)
    }
  }

  # Normalize whitespace if requested
  if (normalize_whitespace) {
    # Replace multiple whitespace with single space
    text <- gsub("\\s+", " ", text)
    # Trim leading/trailing whitespace
    text <- trimws(text)
  }

  # Truncate if max_length specified
  if (!is.null(max_length) && is.numeric(max_length) && max_length > 0) {
    long_text <- nchar(text) > max_length
    if (any(long_text)) {
      text[long_text] <- paste0(substr(text[long_text], 1, max_length - 3), "...")
    }
  }

  return(text)
}

#' Apply Unicode Handling to YouTube API Response
#'
#' Applies consistent Unicode handling to common YouTube API response fields
#'
#' @param response List or data.frame containing YouTube API response data
#' @param text_fields Character vector of field names to process.
#'   Default: common YouTube text fields
#' @return Processed response with proper Unicode handling
#' @keywords internal
process_youtube_text <- function(response,
                                text_fields = c("title", "description", "textDisplay", "textOriginal",
                                               "channelTitle", "authorDisplayName", "categoryId")) {

  # Modern validation using checkmate
  assert_character(text_fields, min.len = 1, .var.name = "text_fields")

  if (is.null(response)) {
    return(response)
  }

  # Handle data.frame responses
  if (is.data.frame(response)) {
    for (field in text_fields) {
      if (field %in% colnames(response)) {
        response[[field]] <- clean_youtube_text(response[[field]])
      }
    }
    return(response)
  }

  # Handle list responses (API response format)
  if (is.list(response)) {
    # Recursively process nested lists
    response <- rapply(response, function(x) {
      if (is.character(x) && length(x) == 1) {
        clean_youtube_text(x)
      } else {
        x
      }
    }, how = "replace")
  }

  return(response)
}
