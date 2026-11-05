#' Unicode and Text Processing Utilities
#'
#' Functions for consistent text and Unicode handling across tuber,
#' including emoji detection, extraction, and manipulation.
#' @name unicode_utils
#' @keywords internal
NULL

# Code points that make a grapheme cluster an emoji:
# - anything Unicode shows as an emoji by default;
# - symbols from U+2600 up that Unicode lists as emoji, such as the sun and
#   the heart, which people type without the emoji variation selector;
# - every pictograph beyond the Basic Multilingual Plane, a range Unicode
#   reserves for emoji, so an emoji newer than the installed ICU still counts;
# - the two marks that turn a text character into an emoji: variation
#   selector 16 and the keycap mark, as in "5" in a box.
# Text symbols such as a black star, (c) and (tm), and plain digits, are not
# emoji unless written with one of those marks.
emoji_class <- paste0(
  "[\\p{Emoji_Presentation}",
  "[\\p{Emoji}&&\\p{Extended_Pictographic}&&[\\u2600-\\uFFFF]]",
  "[\\p{Extended_Pictographic}&&[^\\u0000-\\uFFFF]]",
  "\\uFE0F\\u20E3]"
)

#' Split text into user-perceived characters and flag the emoji
#'
#' A family, a flag, a keycap or a thumbs-up with a skin tone is one emoji to
#' a reader but several code points in the string, so emoji are identified per
#' grapheme cluster rather than per code point. ICU, through stringi, supplies
#' both the cluster boundaries and the Unicode emoji properties, so there is no
#' table of emoji ranges here to fall behind the Unicode standard.
#'
#' @param text Character vector
#' @return A list with one element per string, each a list holding `cluster`
#'   (the characters) and `is_emoji` (logical, same length)
#' @keywords internal
#' @noRd
emoji_clusters <- function(text) {
  lapply(stringi::stri_split_boundaries(text, type = "character"), function(cluster) {
    cluster <- cluster[!is.na(cluster)]
    list(cluster = cluster, is_emoji = stringi::stri_detect_regex(cluster, emoji_class))
  })
}

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
  vapply(emoji_clusters(text), function(x) any(x$is_emoji), logical(1))
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
  lapply(emoji_clusters(text), function(x) x$cluster[x$is_emoji])
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
  vapply(emoji_clusters(text), function(x) sum(x$is_emoji), integer(1))
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
  replace_emojis(text, replacement = "")
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
  assert_string(replacement, .var.name = "replacement")
  replaced <- vapply(emoji_clusters(text), function(x) {
    paste(ifelse(x$is_emoji, replacement, x$cluster), collapse = "")
  }, character(1))
  replaced[is.na(text)] <- NA_character_
  replaced
}
