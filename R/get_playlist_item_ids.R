#' Get Playlist-Item IDs
#'
#' @inheritParams list_playlist_items
#' @return A character vector of playlist-item IDs.
#' @export
#' @examples
#' \dontrun{
#' get_playlist_item_ids(playlist_id = "PLrEnWoR732-CN09YykVof2lxdI3MLOZda")
#' }
get_playlist_item_ids <- function(playlist_id = NULL,
                                  playlist_item_ids = NULL,
                                  video_id = NULL,
                                  max_results = 50,
                                  page_token = NULL,
                                  auth = "key",
                                  ...) {
  result <- list_playlist_items(
    playlist_id = playlist_id,
    playlist_item_ids = playlist_item_ids,
    video_id = video_id,
    part = "id",
    max_results = max_results,
    page_token = page_token,
    simplify = FALSE,
    auth = auth,
    ...
  )
  vapply(result$items %||% list(), function(item) item$id, character(1))
}
