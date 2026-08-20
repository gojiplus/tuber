#' List Channel Sections
#'
#' Returns channel sections matching exactly one supported YouTube filter.
#'
#' @param channel_id Channel whose sections should be returned.
#' @param section_ids One or more channel-section IDs.
#' @param mine Set to `TRUE` to return sections for the authenticated user's
#' channel.
#' @param part Character vector of resource parts to return.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response.
#' @param auth Authentication method, `"token"` or `"key"`. `mine = TRUE`
#' requires `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a channel-section
#' list response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channelSections/list}
#' @examples
#' \dontrun{
#' list_channel_sections(channel_id = "UCRw8bIz2wMLmfgAgWm903cA")
#' list_channel_sections(mine = TRUE, auth = "token")
#' }
list_channel_sections <- function(channel_id = NULL,
                                  section_ids = NULL,
                                  mine = FALSE,
                                  part = c("snippet", "contentDetails"),
                                  simplify = TRUE,
                                  auth = if (mine) "token" else "key",
                                  ...) {
  assert_flag(mine, .var.name = "mine")
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")

  if (!is.null(channel_id)) {
    assert_string(channel_id, min.chars = 1, .var.name = "channel_id")
  }
  if (!is.null(section_ids)) {
    assert_character(section_ids, min.len = 1, min.chars = 1, .var.name = "section_ids")
  }

  filter_count <- sum(!is.null(channel_id), !is.null(section_ids), mine)
  if (filter_count != 1) {
    abort(
      "Supply exactly one of `channel_id`, `section_ids`, or `mine = TRUE`.",
      class = "tuber_invalid_channel_section_filter"
    )
  }
  if (mine && auth != "token") {
    abort(
      "`mine = TRUE` requires OAuth authentication (`auth = \"token\"`).",
      class = "tuber_auth_required"
    )
  }

  query <- list(part = paste(part, collapse = ","))
  if (!is.null(channel_id)) query$channelId <- channel_id
  if (!is.null(section_ids)) query$id <- paste(section_ids, collapse = ",")
  if (mine) query$mine <- "true"

  response <- tuber_GET("channelSections", query = query, auth = auth, ...)
  items <- response$items %||% list()

  if (!simplify) {
    return(add_tuber_attributes(
      response,
      function_name = "list_channel_sections",
      results_found = length(items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(items, function(item) {
    snippet <- item$snippet %||% list()
    content <- item$contentDetails %||% list()
    data.frame(
      section_id = item$id %||% NA_character_,
      channel_id = snippet$channelId %||% NA_character_,
      title = snippet$title %||% NA_character_,
      type = snippet$type %||% NA_character_,
      style = snippet$style %||% NA_character_,
      position = as.integer(snippet$position %||% NA),
      default_language = snippet$defaultLanguage %||% NA_character_,
      localized_title = snippet$localized$title %||% NA_character_,
      playlist_ids = I(list(content$playlists %||% character())),
      channel_ids = I(list(content$channels %||% character())),
      stringsAsFactors = FALSE
    )
  })

  add_tuber_attributes(
    result,
    function_name = "list_channel_sections",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
