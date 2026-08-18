#' List Video Categories
#'
#' Lists video categories by region or by category ID.
#'
#' @param region_code Optional ISO 3166-1 alpha-2 content-region code.
#' @param category_ids Optional character vector of video-category IDs.
#' @param language Optional language code for localized text.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame with one row per category and snake-case column names.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videoCategories/list}
#' @examples
#' \dontrun{
#' list_video_categories(region_code = "JP")
#' list_video_categories(category_ids = "10")
#' }
list_video_categories <- function(region_code = NULL,
                                  category_ids = NULL,
                                  language = NULL,
                                  auth = "key",
                                  ...) {
  if (!is.null(region_code)) {
    assert_string(region_code, pattern = "^[A-Z]{2}$", .var.name = "region_code")
  }
  if (!is.null(category_ids)) {
    assert_character(
      category_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "category_ids"
    )
  }
  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
  }
  assert_choice(auth, c("key", "token"), .var.name = "auth")

  if (sum(!is.null(region_code), !is.null(category_ids)) != 1) {
    abort(
      "Supply exactly one of `region_code` or `category_ids`.",
      class = "tuber_invalid_video_category_filter"
    )
  }

  response <- tuber_GET(
    "videoCategories",
    query = list(
      part = "snippet",
      regionCode = region_code,
      id = if (is.null(category_ids)) NULL else paste(category_ids, collapse = ","),
      hl = language
    ),
    auth = auth,
    ...
  )
  items <- response$items %||% list()

  result <- if (length(items) == 0) {
    data.frame(
      category_id = character(),
      title = character(),
      assignable = logical(),
      channel_id = character(),
      region_code = character(),
      etag = character(),
      stringsAsFactors = FALSE
    )
  } else {
    items_to_frame(items, function(item) {
      data.frame(
        category_id = item$id %||% NA_character_,
        title = item$snippet$title %||% NA_character_,
        assignable = item$snippet$assignable %||% NA,
        channel_id = item$snippet$channelId %||% NA_character_,
        region_code = region_code %||% NA_character_,
        etag = item$etag %||% NA_character_,
        stringsAsFactors = FALSE
      )
    })
  }

  add_tuber_attributes(
    result,
    function_name = "list_video_categories",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
