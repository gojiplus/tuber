#' Returns List of Requested Channel Resources
#'
#' @param filter string; Required.
#' named vector with a single valid name
#' potential names of the entry in the vector:
#' \code{category_id}: YouTube guide category that returns channels associated
#' with that category
#' \code{username}:  YouTube username that returns the channel associated with that
#'  username. Multiple usernames can be provided.
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
#' @return list. If \code{username} is used in \code{filter},
#'   a data frame with columns \code{username} and \code{channel_id} is returned.
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
#' list_channel_resources(filter = c(username = "latenight"), part = "id")
#' list_channel_resources(filter = c(username = c("latenight", "PBS")),
#'                        part = "id")
#' }

list_channel_resources <- function(filter = NULL, part = "contentDetails",
                         max_results = 50, page_token = NULL, hl = "en-US", ...) {
  
  # Modern validation using checkmate
  assert_character(filter, min.len = 1, .var.name = "filter")
  assert_choice(part, c("auditDetails", "brandingSettings", "contentDetails", 
                        "contentOwnerDetails", "id", "invideoPromotion", 
                        "localizations", "snippet", "statistics", "status", 
                        "topicDetails"), .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_character(hl, len = 1, min.chars = 1, .var.name = "hl")
  
  if (!is.null(page_token)) {
    assert_character(page_token, len = 1, min.chars = 1, .var.name = "page_token")
  }
  
  # Validate filter names
  if (!all(names(filter) == names(filter)[1])) {
    abort("filter must have a single valid name",
          filter_names = names(filter),
          class = "tuber_mixed_filter_names")
  }
  
  filter_name <- names(filter)[1]
  assert_choice(filter_name, c("category_id", "username", "channel_id"), 
                .var.name = "filter name")
  
  if (filter_name != "username" && length(filter) != 1) {
    abort("filter must be a vector of length 1 for channel_id or category_id",
          filter_name = filter_name,
          filter_length = length(filter),
          class = "tuber_invalid_filter_length")
  }
  
  # Check for username BEFORE translation
  if (names(filter)[1] == "username") {
    usernames <- unname(filter)
    num_usernames <- length(usernames)
    res_df <- data.frame(username = usernames,
                         channel_id = rep(NA_character_, num_usernames),
                         stringsAsFactors = FALSE)

    for (i in seq_along(usernames)) {
      querylist <- list(part = part, maxResults = max_results,
                        pageToken = page_token, hl = hl, forUsername = usernames[i])

      # Add retry logic for intermittent API issues
      max_retries <- 3
      retry_count <- 0
      res <- NULL
      
      while (retry_count < max_retries && (is.null(res) || length(res$items) == 0)) {
        if (retry_count > 0) {
          Sys.sleep(0.5)  # Brief pause before retry
        }
        
        tryCatch({
          res <- tuber_GET("channels", querylist, ...)
        }, error = function(e) {
          warn("Error fetching username",
               username = usernames[i],
               error = e$message,
               class = "tuber_username_fetch_error")
          res <<- NULL
        })
        
        retry_count <- retry_count + 1
      }

      # Robust error handling and data extraction
      if (is.null(res) || length(res$items) == 0) {
        warn("No channel found for username after multiple attempts",
             username = usernames[i],
             max_retries = max_retries,
             possible_causes = c("username doesn't exist", "channel was deleted", "username was changed to custom URL"),
             class = "tuber_username_not_found")
        res_df$channel_id[i] <- NA_character_
      } else {
        # Safely extract channel ID with multiple fallbacks
        item <- res$items[[1]]
        if (!is.null(item$id)) {
          res_df$channel_id[i] <- item$id
        } else {
          warn("Channel found for username but no ID returned",
               username = usernames[i],
               help = "API response may be incomplete",
               class = "tuber_incomplete_response")
          res_df$channel_id[i] <- NA_character_
        }
      }

      if (interactive()) {
        cat(sprintf("Processed %d/%d usernames\n", i, num_usernames))
      }
    }

    return(res_df)
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

