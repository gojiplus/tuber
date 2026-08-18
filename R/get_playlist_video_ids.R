#' Get Video IDs from a Playlist
#'
#' @param playlist_id Playlist ID.
#' @param max_results Maximum total number of video IDs to return.
#' @param page_token Optional page token at which to start.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [list_playlist_items()].
#' @return A character vector of video IDs.
#' @export
#' @examples
#' \dontrun{
#' get_playlist_video_ids("PLrEnWoR732-CN09YykVof2lxdI3MLOZda")
#' }
get_playlist_video_ids <- function(playlist_id,
                                   max_results = 50,
                                   page_token = NULL,
                                   auth = "key",
                                   ...) {
  result <- list_playlist_items(
    playlist_id = playlist_id,
    part = "contentDetails",
    max_results = max_results,
    page_token = page_token,
    simplify = TRUE,
    auth = auth,
    ...
  )
  result$video_id
}
