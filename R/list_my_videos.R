#' List My videos
#'
#' @param ... additional arguments to pass to \code{\link{list_channel_videos}}
#'
#' @return \code{data.frame} with each list corresponding to a different
#' playlist
#' @export
#'
#' @examples \dontrun{
#'   list_my_videos()
#' }
#'
list_my_videos = function(...) {
  x = get_channel_stats(mine = TRUE)
  res = list_channel_videos(channel_id = x$id, ...)
  return(res)
}
