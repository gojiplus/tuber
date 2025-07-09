#' Returns List of Requested Channel Resources
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{category_id}: YouTube guide category that returns channels associated
#' with that category
#' \code{username}:  YouTube username that returns the channel associated with that
#'  username.
#' \code{channel_id}: a comma-separated list of the YouTube channel ID(s) for
#' the resource(s) that are being retrieved
#'
#' @param part a comma-separated list of channel resource properties that
#' response will include a string. Required.
#' One of the following: \code{auditDetails, brandingSettings, contentDetails,
#' contentOwnerDetails, id, invideoPromotion, localizations, snippet,
#' statistics, status, topicDetails}.
#' Default is \code{contentDetails}.
#' @param hl  Language used for text values. Optional. The default is \code{en-US}.
#' For other allowed language codes, see \code{\link{list_langs}}.
#' @param max_results Maximum number of items that should be returned. Integer.
#'  Optional. Default is 50. Values over 50 will trigger additional requests and
#'  may increase API quota usage.
#' @param page_token specific page in the result set that should be returned,
#' optional
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return list
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#'
#' @examples
#'
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_channel_resources(filter = c(channel_id = "UCT5Cx1l4IS3wHkJXNyuj4TA"))
#' list_channel_resources(filter = c(username = "latenight"), part = "id, contentDetails")
#' list_channel_resources(filter = c(username = "latenight"), part = "id, contentDetails",
#' max_results = 10)
#' }

list_channel_resources <- function(filter = NULL, part = "contentDetails",
                         max_results = 50, page_token = NULL, hl = "en-US", ...) {
  if (max_results <= 0) {
    stop("max_results must be a positive integer.")
  }
  if (!(names(filter) %in% c("category_id", "username", "channel_id"))) {
    stop("filter can only take one of three values: category_id,
      username or channel_id.")
  }
  if (length(filter) != 1) stop("filter must be a vector of length 1.")
  
  # Check for username BEFORE translation
  if ("username" %in% names(filter)) {
    usernames <- filter[names(filter) == "username"]  # Use bracket indexing
    num_usernames <- length(usernames)
    channel_ids <- vector("list", length = num_usernames)
    
    for (i in seq_along(usernames)) {
      querylist <- list(part = part, maxResults = max_results,
                        pageToken = page_token, hl = hl, forUsername = usernames[i])
      
      res <- tuber_GET("channels", querylist, ...)
      
      if (length(res$items) == 0) {
        warning("No details available for username: ", usernames[i])
      } else {
        channel_ids[[i]] <- res$items[[1]]$id
      }
      
      print(i)
    }
    
    return(channel_ids)
  }
  
  # Translate filter names for non-username cases
  translate_filter   <- c(channel_id = "id", category_id = "categoryId",
                          username = "forUsername")
  yt_filter_name     <- as.vector(translate_filter[match(names(filter),
                                                      names(translate_filter))])
  names(filter)      <- yt_filter_name
  
  querylist <- list(part = part, maxResults = min(max_results, 50),
                    pageToken = page_token, hl = hl)
  querylist <- c(querylist, filter)

  res <- tuber_GET("channels", querylist, ...)
  items <- res$items
  next_token <- res$nextPageToken

  while (length(items) < max_results && !is.null(next_token)) {
    querylist$pageToken <- next_token
    querylist$maxResults <- min(50, max_results - length(items))
    a_res <- tuber_GET("channels", querylist, ...)
    items <- c(items, a_res$items)
    next_token <- a_res$nextPageToken
  }

  res$items <- items
  res
}

