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
#'  Optional. Can be between 0 and 50. The default is 50.
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
  if (max_results < 0 | max_results > 50) {
    stop("max_results only takes a value between 0 and 50.")
  }
  if (!all(names(filter) == names(filter)[1])) {
    stop("filter must have a single valid name")
  }
  if (!(names(filter)[1] %in% c("category_id", "username", "channel_id"))) {
    stop("filter can only take one of three values: category_id, username or channel_id.")
  }
  if (names(filter)[1] != "username" && length(filter) != 1) {
    stop("filter must be a vector of length 1 for channel_id or category_id.")
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

      res <- tuber_GET("channels", querylist, ...)

      if (length(res$items) == 0) {
        warning("No details available for username: ", usernames[i])
      } else {
        res_df$channel_id[i] <- res$items[[1]]$id
      }

      print(paste0(i, "/", num_usernames))
    }

    return(res_df)
  }
  
  # Translate filter names for non-username cases
  translate_filter   <- c(channel_id = "id", category_id = "categoryId",
                          username = "forUsername")
  yt_filter_name     <- as.vector(translate_filter[match(names(filter),
                                                      names(translate_filter))])
  names(filter)      <- yt_filter_name
  
  querylist <- list(part = part, maxResults = max_results,
                    pageToken = page_token, hl = hl)
  querylist <- c(querylist, filter)
  
  res <- tuber_GET("channels", querylist, ...)
  
  res
}

