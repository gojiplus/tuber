#' Get Channel Details
#'
#' Retrieves channels by ID, legacy username, guide category, or the
#' authenticated user's channel. Supply exactly one filter.
#'
#' @param channel_ids Optional character vector of channel IDs.
#' @param usernames Optional character vector of legacy YouTube usernames.
#' @param category_id Optional guide-category ID.
#' @param mine If `TRUE`, retrieve the authenticated user's channel.
#' @param part Character vector of channel resource parts.
#' @param max_results Maximum number of category-filtered channels to return.
#' @param language Optional language code for localized text.
#' @param simplify If `TRUE`, return a data frame; otherwise return a channels
#' list response with all collected items.
#' @param batch_size Number of channel IDs per request, at most 50.
#' @param auth Authentication method, `"key"` or `"token"`. `mine = TRUE`
#' requires OAuth.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a channels-list
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' @examples
#' \dontrun{
#' get_channel_details(channel_ids = "UCT5Cx1l4IS3wHkJXNyuj4TA")
#' get_channel_details(usernames = c("GoogleDevelopers", "PBS"))
#' get_my_channel()
#' }
get_channel_details <- function(channel_ids = NULL,
                                usernames = NULL,
                                category_id = NULL,
                                mine = FALSE,
                                part = c("snippet", "statistics"),
                                max_results = 50,
                                language = NULL,
                                simplify = TRUE,
                                batch_size = 50,
                                auth = if (mine) "token" else "key",
                                ...) {
  assert_flag(mine, .var.name = "mine")
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(channel_ids)) {
    assert_character(
      channel_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "channel_ids"
    )
  }
  if (!is.null(usernames)) {
    assert_character(
      usernames,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "usernames"
    )
  }
  if (!is.null(category_id)) {
    assert_string(category_id, min.chars = 1, .var.name = "category_id")
  }
  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
  }

  filter_count <- sum(
    !is.null(channel_ids),
    !is.null(usernames),
    !is.null(category_id),
    mine
  )
  if (filter_count != 1) {
    abort(
      paste0(
        "Supply exactly one of `channel_ids`, `usernames`, `category_id`, or ",
        "`mine = TRUE`."
      ),
      class = "tuber_invalid_channel_filter"
    )
  }
  if (mine && auth != "token") {
    abort("`mine = TRUE` requires OAuth authentication.", class = "tuber_auth_required")
  }

  part_query <- paste(part, collapse = ",")
  request <- function(query) {
    call_api_with_retry(
      tuber_GET,
      path = "channels",
      query = query,
      auth = auth,
      ...
    )
  }
  items <- list()
  api_calls <- 0L

  if (!is.null(channel_ids)) {
    channel_ids <- unique(channel_ids)
    batches <- split(channel_ids, ceiling(seq_along(channel_ids) / batch_size))
    for (batch in batches) {
      response <- request(list(
        part = part_query,
        id = paste(batch, collapse = ","),
        hl = language
      ))
      items <- c(items, response$items %||% list())
      api_calls <- api_calls + 1L
    }
  } else if (!is.null(usernames)) {
    usernames <- unique(usernames)
    for (username in usernames) {
      response <- request(list(
        part = part_query,
        forUsername = username,
        hl = language
      ))
      items <- c(items, response$items %||% list())
      api_calls <- api_calls + 1L
    }
  } else if (!is.null(category_id)) {
    query <- list(
      part = part_query,
      categoryId = category_id,
      hl = language,
      maxResults = min(max_results, 50)
    )
    fetch_page <- function(token = NULL) {
      page_query <- query
      page_query$pageToken <- token
      request(page_query)
    }
    first_page <- fetch_page()
    pages <- paginate_api_request(first_page, fetch_page, max_results = max_results)
    items <- pages$items
    api_calls <- pages$page_count
  } else {
    response <- request(list(part = part_query, mine = "true", hl = language))
    items <- response$items %||% list()
    api_calls <- 1L
  }

  response <- list(
    kind = "youtube#channelListResponse",
    items = items,
    pageInfo = list(totalResults = length(items), resultsPerPage = length(items))
  )
  result <- if (simplify) flatten_channel_data(items) else response

  add_tuber_attributes(
    result,
    api_calls_made = api_calls,
    function_name = "get_channel_details",
    results_found = length(items),
    response_format = if (simplify) "data.frame" else "list"
  )
}

#' @rdname get_channel_details
#' @export
get_my_channel <- function(part = c("snippet", "statistics"),
                           language = NULL,
                           simplify = TRUE,
                           ...) {
  get_channel_details(
    mine = TRUE,
    part = part,
    language = language,
    simplify = simplify,
    ...
  )
}

flatten_channel_data <- function(items) {
  items_to_frame(items, function(item) {
    data.frame(
      channel_id = item$id %||% NA_character_,
      title = item$snippet$title %||% NA_character_,
      description = item$snippet$description %||% NA_character_,
      published_at = item$snippet$publishedAt %||% NA_character_,
      country = item$snippet$country %||% NA_character_,
      default_language = item$snippet$defaultLanguage %||% NA_character_,
      custom_url = item$snippet$customUrl %||% NA_character_,
      thumbnail_url = item$snippet$thumbnails$default$url %||% NA_character_,
      view_count = as.numeric(item$statistics$viewCount %||% NA),
      subscriber_count = as.numeric(item$statistics$subscriberCount %||% NA),
      video_count = as.numeric(item$statistics$videoCount %||% NA),
      subscriber_count_hidden = item$statistics$hiddenSubscriberCount %||% NA,
      uploads_playlist = item$contentDetails$relatedPlaylists$uploads %||% NA_character_,
      likes_playlist = item$contentDetails$relatedPlaylists$likes %||% NA_character_,
      keywords = item$brandingSettings$channel$keywords %||% NA_character_,
      unsubscribed_trailer = item$brandingSettings$channel$unsubscribedTrailer %||% NA_character_,
      kind = item$kind %||% NA_character_,
      etag = item$etag %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
}
