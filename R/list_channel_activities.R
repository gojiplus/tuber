#' List Channel Activity
#'
#' Returns a list of channel events that match the request criteria.
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{channel_id}: ID of the channel. Required. No default.
#'
#' @param part specify which part do you want. It can only be one of the three:
#'  \code{contentDetails, id, snippet}. Default is \code{snippet}.
#' @param max_results Maximum number of items that should be returned. Integer.
#'  Optional. Default is 50. Values over 50 will trigger additional requests and
#'  may increase API quota usage.
#' @param page_token specific page in the result set that should be returned,
#' optional
#' @param published_after Character. Optional. RFC 339 Format. For instance,
#' "1970-01-01T00:00:00Z"
#' @param published_before Character. Optional. RFC 339 Format. For instance,
#' "1970-01-01T00:00:00Z"
#' @param region_code  ISO 3166-1 alpha-2 country code, optional, see also
#' \code{\link{list_regions}}
#' @param simplify Data Type: Boolean. Default is \code{TRUE}. If \code{TRUE}
#' and if part requested is \code{contentDetails},
#' the function returns a \code{data.frame}. Else a list with all the
#'  information returned.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return named list
#' If \code{simplify} is \code{TRUE}, a data.frame is returned with 18 columns:
#' \code{publishedAt, channelId, title, description, thumbnails.default.url,
#' thumbnails.default.width, thumbnails.default.height,
#' thumbnails.medium.url, thumbnails.medium.width, thumbnails.medium.height,
#' thumbnails.high.url, thumbnails.high.width,
#' thumbnails.high.height, thumbnails.standard.url, thumbnails.standard.width,
#' thumbnails.standard.height, channelTitle, type}
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/activities/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_channel_activities(filter = c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA"))
#' list_channel_activities(filter = c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA", regionCode="US"))
#' list_channel_activities(filter = c(channel_id = "UCMtFAi84ehTSYSE9XoHefig"),
#'                         published_before = "2016-02-10T00:00:00Z",
#'                         published_after = "2016-01-01T00:00:00Z")
#' }

list_channel_activities <- function(filter = NULL, part = "snippet",
                                    max_results = 50, page_token = NULL,
                                    published_after = NULL,
                                    published_before = NULL, region_code = NULL,
                                    simplify = TRUE, ...) {

  # Modern validation using checkmate
  assert_character(filter, len = 1, .var.name = "filter")
  assert_choice(names(filter), "channel_id", .var.name = "filter names (must be 'channel_id')")
  assert_choice(part, c("contentDetails", "id", "snippet"), .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")
  
  if (!is.null(page_token)) {
    assert_character(page_token, len = 1, min.chars = 1, .var.name = "page_token")
  }
  
  if (!is.null(published_after)) {
    assert_character(published_after, len = 1, .var.name = "published_after")
    if (is.na(as.POSIXct(published_after, format = "%Y-%m-%dT%H:%M:%SZ"))) {
      abort("published_after is not properly formatted in RFC 339 Format",
            date = published_after,
            expected_format = "YYYY-MM-DDTHH:MM:SSZ",
            class = "tuber_invalid_date_format")
    }
  }
  
  if (!is.null(published_before)) {
    assert_character(published_before, len = 1, .var.name = "published_before")
    if (is.na(as.POSIXct(published_before, format = "%Y-%m-%dT%H:%M:%SZ"))) {
      abort("published_before is not properly formatted in RFC 339 Format",
            date = published_before,
            expected_format = "YYYY-MM-DDTHH:MM:SSZ",
            class = "tuber_invalid_date_format")
    }
  }
  
  if (!is.null(region_code)) {
    assert_character(region_code, len = 1, pattern = "^[A-Z]{2}$", .var.name = "region_code")
  }

  translate_filter   <- c(channel_id = "channelId")
  yt_filter_name     <- as.vector(translate_filter[match(names(filter),
                                                      names(translate_filter))])
  names(filter)      <- yt_filter_name

  querylist <- list(part = part, maxResults = min(max_results, 50),
                    pageToken = page_token, publishedAfter = published_after,
                    publishedBefore = published_before,
                    regionCode = region_code)
  querylist <- c(querylist, filter)

  raw_res <- tuber_GET("activities", querylist, ...)
  items <- raw_res$items
  next_token <- raw_res$nextPageToken

  while (length(items) < max_results && !is.null(next_token)) {
    querylist$pageToken <- next_token
    querylist$maxResults <- min(50, max_results - length(items))
    a_res <- tuber_GET("activities", querylist, ...)
    items <- c(items, a_res$items)
    next_token <- a_res$nextPageToken
  }

  raw_res$items <- items

   if (length(raw_res$items) == 0) {
      warn("No activity information available. Likely cause: Incorrect channel ID",
           channel_id = unname(filter)[1],
           class = "tuber_no_activities")
      if (simplify == TRUE) return(data.frame())
      return(list())
    }

    if (simplify == TRUE & part == "snippet") {
    simple_res  <- lapply(raw_res$items, function(x) unlist(x$snippet))
    simpler_res <- ldply(simple_res, rbind)
    return(simpler_res)
  }

   raw_res
}
