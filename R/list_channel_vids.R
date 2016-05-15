#' List All the Videos in a Channel
#' 
#' @param channel_name string, channel name, required
#' 
#' @return data.frame with 3 columns: hl (two letter abbreviation), name (of the language), etag
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' @examples
#' \dontrun{
#' list_channel_videos("latenight")
#' }

list_channel_videos <- function (channel_name=NULL) 
{
     querylist <- list(part = "contentDetails", forUserName = channel_name)
     res <- tuber_GET("channels", querylist)
     resdf <- NA
     if (length(res$items) != 0) {
          simple_res <- lapply(res$items, function(x) c(unlist(x$snippet), 
                                                        etag = x$etag))
          resdf <- as.data.frame(do.call(rbind, simple_res))
     }
     else {
          resdf <- 0
     }
     cat("Total Number of Videos:", length(res$items), "\n")
     return(invisible(resdf))
}
