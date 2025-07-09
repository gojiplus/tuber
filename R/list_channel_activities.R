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

  if (max_results <= 0) {
    stop("max_results must be a positive integer.")
  }

  if (!(names(filter) %in% c("channel_id"))) {
    stop("filter can only take one of values: channel_id.")
  }

  if ( length(filter) != 1) stop("filter must be a vector of length 1.")

  if (is.character(published_after))  {
    if (is.na(as.POSIXct(published_after, format = "%Y-%m-%dT%H:%M:%SZ"))) {
      stop("The date is not properly formatted in RFC 339 Format.")
    }
  }

  if (is.character(published_before)) {
    if (is.na(as.POSIXct(published_before, format = "%Y-%m-%dT%H:%M:%SZ"))) {
      stop("The date is not properly formatted in RFC 339 Format.")
    }
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
      warning("No comment information available. Likely cause: Incorrect ID.\n")
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
