#' List Video-Abuse Report Reasons
#'
#' @param part Character vector of resource parts.
#' @param language Language code for localized labels.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame with one row per primary report reason.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videoAbuseReportReasons/list}
#' @examples
#' \dontrun{
#' list_abuse_report_reasons()
#' }
list_abuse_report_reasons <- function(part = c("id", "snippet"),
                                      language = "en-US",
                                      auth = "key",
                                      ...) {
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_string(language, min.chars = 1, .var.name = "language")
  assert_choice(auth, c("key", "token"), .var.name = "auth")

  response <- tuber_GET(
    "videoAbuseReportReasons",
    query = list(part = paste(part, collapse = ","), hl = language),
    auth = auth,
    ...
  )
  items <- response$items %||% list()

  result <- if (length(items) == 0) {
    data.frame(
      reason_id = character(),
      label = character(),
      secondary_reason_ids = character(),
      etag = character(),
      stringsAsFactors = FALSE
    )
  } else {
    items_to_frame(items, function(item) {
      secondary <- item$snippet$secondaryReasons %||% list()
      data.frame(
        reason_id = item$id %||% NA_character_,
        label = item$snippet$label %||% NA_character_,
        secondary_reason_ids = paste(
          vapply(secondary, function(reason) reason$id %||% NA_character_, character(1)),
          collapse = ","
        ),
        etag = item$etag %||% NA_character_,
        stringsAsFactors = FALSE
      )
    })
  }

  add_tuber_attributes(
    result,
    function_name = "list_abuse_report_reasons",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
