#' List Captions of a Video
#' 
#' For getting captions from the v3 API, you must specify the id resource. 
#' Check \code{\link{list_caption_tracks}} for more information.
#' 
#' @param video_id ID of the video whose captions are requested. Required. No default.
#' @param id    String. Optional. id of the caption track that is being retrieved
#' @param part Required. Default is \code{snippet}. It can also be \code{id}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return String. 
#' 
#' @export
#'  
#' @examples
#' \dontrun{
#' 
#' # Set API token via yt_oauth() first
#' 
#' list_captions(video_id = "yJXTXN4xrI8")
#' }

list_captions <- function (video_id = NULL, part = "snippet", id = NULL, ...) {

  if ( !is.character(video_id)) {
    stop("Must specify a valid video_id.")
  }
  
  querylist <- list(videoId = video_id, part = part, id = id)
  raw_res <- tuber_GET("captions", query = querylist, ...)

  if (length(raw_res$items) == 0) {
    warning("No caption tracks available. Likely cause:
             Incorrect video ID. \n")
    return(list())
  }

  raw_res
}
