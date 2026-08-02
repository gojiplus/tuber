#' Unicode and Text Processing Utilities
#'
#' Functions for consistent text and Unicode handling across tuber,
#' including emoji detection, extraction, and manipulation.
#' @name unicode_utils
NULL

#' Emoji Unicode Pattern
#'
#' Comprehensive regex pattern covering major emoji Unicode blocks:
#' - Emoticons (U+1F600-U+1F64F)
#' - Miscellaneous Symbols and Pictographs (U+1F300-U+1F5FF)
#' - Transport and Map Symbols (U+1F680-U+1F6FF)
#' - Flags (U+1F1E0-U+1F1FF)
#' - Dingbats (U+2700-U+27BF)
#' - Supplemental Symbols and Pictographs (U+1F900-U+1F9FF)
#' - Symbols and Pictographs Extended-A (U+1FA00-U+1FAFF)
#' - Miscellaneous Symbols (U+2600-U+26FF)
#' - Various common emoji symbols
#'
#' @keywords internal
EMOJI_PATTERN <- paste0(
"[",
"\U0001F600-\U0001F64F",
"\U0001F300-\U0001F5FF",
"\U0001F680-\U0001F6FF",
"\U0001F1E0-\U0001F1FF",
"\U00002702-\U000027B0",
"\U0001F900-\U0001F9FF",
"\U0001FA00-\U0001FA6F",
"\U0001FA70-\U0001FAFF",
"\U00002600-\U000026FF",
"\U0000231A-\U0000231B",
"\U00002328",
"\U000023CF",
"\U000023E9-\U000023F3",
"\U000023F8-\U000023FA",
"\U00002934-\U00002935",
"\U000025AA-\U000025AB",
"\U000025B6",
"\U000025C0",
"\U000025FB-\U000025FE",
"\U00002B05-\U00002B07",
"\U00002B1B-\U00002B1C",
"\U00002B50",
"\U00002B55",
"\U00003030",
"\U0000303D",
"\U00003297",
"\U00003299",
"\U0000FE0F",
"]"
)

#' Detect emojis in text
#'
#' Checks whether text contains any emoji characters.
#'
#' @param text Character vector to check for emojis
#' @return Logical vector indicating whether each element contains emojis
#' @export
#' @examples
#' has_emoji("Hello world")
#' has_emoji("Hello world! \U0001F44B")
#' has_emoji(c("No emoji", "Has emoji \U0001F600", "Also none"))
has_emoji <- function(text) {
  if (is.null(text) || length(text) == 0) {
    return(logical(0))
  }
  assert_character(text, .var.name = "text")
  grepl(EMOJI_PATTERN, text, perl = TRUE)
}

#' Extract emojis from text
#'
#' Extracts all emoji characters from text.
#'
#' @param text Character vector to extract emojis from
#' @return List of character vectors, one per input element, containing
#'   extracted emojis. Returns empty character vector for elements without emojis.
#' @export
#' @examples
#' extract_emojis("Hello \U0001F44B World \U0001F30D!")
#' extract_emojis(c("No emoji", "\U0001F600 \U0001F601 \U0001F602"))
extract_emojis <- function(text) {
  if (is.null(text) || length(text) == 0) {
    return(list())
  }
  assert_character(text, .var.name = "text")

  lapply(text, function(t) {
    if (is.na(t)) return(character(0))
    matches <- gregexpr(EMOJI_PATTERN, t, perl = TRUE)
    result <- regmatches(t, matches)[[1]]
    if (length(result) == 0) character(0) else result
  })
}

#' Count emojis in text
#'
#' Counts the number of emoji characters in text.
#'
#' @param text Character vector to count emojis in
#' @return Integer vector with emoji counts for each element
#' @export
#' @examples
#' count_emojis("Hello world")
#' count_emojis("Hello \U0001F44B World \U0001F30D!")
#' count_emojis(c("No emoji", "\U0001F600\U0001F601\U0001F602"))
count_emojis <- function(text) {
  if (is.null(text) || length(text) == 0) {
    return(integer(0))
  }
  assert_character(text, .var.name = "text")

  vapply(text, function(t) {
    if (is.na(t)) return(0L)
    matches <- gregexpr(EMOJI_PATTERN, t, perl = TRUE)[[1]]
    if (matches[1] == -1) 0L else length(matches)
  }, integer(1), USE.NAMES = FALSE)
}

#' Remove emojis from text
#'
#' Removes all emoji characters from text.
#'
#' @param text Character vector to remove emojis from
#' @return Character vector with emojis removed
#' @export
#' @examples
#' remove_emojis("Hello \U0001F44B World!")
#' remove_emojis(c("No emoji", "Has \U0001F600 emoji"))
remove_emojis <- function(text) {
  if (is.null(text) || length(text) == 0) {
    return(character(0))
  }
  assert_character(text, .var.name = "text")
  gsub(EMOJI_PATTERN, "", text, perl = TRUE)
}

#' Replace emojis in text
#'
#' Replaces all emoji characters with a specified string.
#'
#' @param text Character vector to process
#' @param replacement String to replace emojis with. Default: "" (empty string)
#' @return Character vector with emojis replaced
#' @export
#' @examples
#' replace_emojis("Hello \U0001F44B World!", replacement = "[emoji]")
#' replace_emojis("Rate: \U0001F600\U0001F600\U0001F600", replacement = "*")
replace_emojis <- function(text, replacement = "") {
  if (is.null(text) || length(text) == 0) {
    return(character(0))
  }
  assert_character(text, .var.name = "text")
  assert_character(replacement, len = 1, .var.name = "replacement")
  gsub(EMOJI_PATTERN, replacement, text, perl = TRUE)
}

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
