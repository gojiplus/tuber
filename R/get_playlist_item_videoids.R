#' Get Playlist Item Video IDs
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{item_id}: comma-separated list of one or more unique playlist item IDs.
#' \code{playlist_id}: YouTube playlist ID.
#'
#' @param part Required. Comma separated string including one or more of the
#' following: \code{contentDetails, id, snippet, status}. Default:
#' \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned.
#' Integer. Optional. Default is 50.
#' If over 50, all the results are returned.
#' @param simplify returns a data.frame rather than a list.
#' @param page_token specific page in the result set that should be
#' returned, optional
#' @param video_id  Optional. request should return only the playlist
#' items that contain the specified video.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return playlist items
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_playlist_items(filter =
#'                        c(playlist_id = "YourPlaylistID"))
#' get_playlist_items(filter =
#'                        c(playlist_id = "YourPlaylistID"),
#'                        max_results = 51)
#' }

get_playlist_item_videoids <- function(filter = NULL, part = "contentDetails",
                                  max_results = 50, video_id = NULL,
                                  page_token = NULL, simplify = TRUE, ...) {

  if (max_results < 0 || max_results > 50) {
    stop("max_results must be a value between 0 and 50.")
  }

  valid_filters <- c("item_id", "playlist_id")
  if (!(names(filter) %in% valid_filters)) {
    stop("filter can only take one of the following values: item_id, playlist_id.")
  }

  if (length(filter) != 1) {
    stop("filter must be a vector of length 1.")
  }

  translate_filter <- c(item_id = "id", playlist_id = "playlistId")
  filter_name <- translate_filter[names(filter)]
  names(filter) <- filter_name

  querylist <- list(part = part,
                    maxResults = max(min(max_results, 50), 1),
                    pageToken = page_token, videoId = video_id)
  querylist <- c(querylist, filter)

  res <- tuber_GET("playlistItems", querylist, ...)
  res_items <- res$items

  item_ids <- rep("", length(res_items))
  for(i in 1:length(res_items)){
    item_ids[i] <- res_items[[i]]$contentDetails$videoId
  }
  return(item_ids)
}


