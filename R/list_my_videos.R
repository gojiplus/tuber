#' List My Videos
#'
#' Lists videos in the authenticated channel's uploads playlist.
#'
#' @param max_results Maximum total number of videos to return.
#' @param page_token Optional page token at which to start.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw
#' playlist-items response.
#' @param ... Additional arguments passed to [tuber_GET()].
#' @return A data frame when `simplify = TRUE`; otherwise a playlist-items
#' response.
#' @export
#' @examples
#' \dontrun{
#' list_my_videos(max_results = 100)
#' }
list_my_videos <- function(max_results = 50,
                           page_token = NULL,
                           simplify = TRUE,
                           ...) {
  channel <- get_my_channel(part = "id", simplify = TRUE)
  if (nrow(channel) == 0) {
    abort("No channel is associated with the authenticated account.", class = "tuber_my_channel_empty")
  }
  list_channel_videos(
    channel_id = channel$channel_id[[1]],
    max_results = max_results,
    page_token = page_token,
    simplify = simplify,
    auth = "token",
    ...
  )
}
