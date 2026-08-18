#' List Supported Content Regions
#'
#' @param language Optional language code for localized names.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame with `region_code`, `name`, and `etag` columns.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/i18nRegions/list}
#' @examples
#' \dontrun{
#' list_regions()
#' }
list_regions <- function(language = NULL, auth = "key", ...) {
  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
  }
  assert_choice(auth, c("key", "token"), .var.name = "auth")

  response <- tuber_GET(
    "i18nRegions",
    query = list(part = "snippet", hl = language),
    auth = auth,
    ...
  )
  items <- response$items %||% list()

  result <- if (length(items) == 0) {
    data.frame(
      region_code = character(),
      name = character(),
      etag = character(),
      stringsAsFactors = FALSE
    )
  } else {
    items_to_frame(items, function(item) {
      data.frame(
        region_code = item$snippet$gl %||% NA_character_,
        name = item$snippet$name %||% NA_character_,
        etag = item$etag %||% NA_character_,
        stringsAsFactors = FALSE
      )
    })
  }

  add_tuber_attributes(
    result,
    function_name = "list_regions",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
