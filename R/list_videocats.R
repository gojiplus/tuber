#' List of Categories That Can be Associated with Videos
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{region_code}: Character. Required. Has to be a ISO 3166-1 alpha-2
#' code (see \url{https://www.iso.org/obp/ui/#search})
#' \code{category_id}: video category ID
#'
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return data.frame with 6 columns: \code{region_code, channelId, title, assignable, etag, id}
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videoCategories/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_videocats(c(region_code = "JP"))
#' list_videocats() # Will throw an error asking for a valid filter with valid region_code
#' }

list_videocats <- function(filter = NULL, ...) {

  # Modern validation using checkmate
  assert_character(filter, len = 1, .var.name = "filter")
  valid_filters <- c("category_id", "region_code")
  assert_choice(names(filter), valid_filters,
                .var.name = "filter names (must be 'category_id' or 'region_code')")

  translate_filter <- c(category_id = "id", region_code = "regionCode")
  yt_filter_name <- translate_filter[names(filter)]
  names(filter) <- yt_filter_name

  querylist <- list(part = "snippet", filter)

  res <- tuber_GET("videoCategories", querylist, ...)

  # Cat total results
  cat("Total Number of Categories:", length(res$items), "\n")

  resdf <- data.frame(region_code = filter$regionCode,
                      channelId = character(),
                      title = character(),
                      assignable = logical(),
                      etag = character(),
                      id = character(),
                      stringsAsFactors = FALSE)

  if (length(res$items) > 0) {
    simple_res <- lapply(res$items, function(x) {
      c(unlist(x$snippet), etag = x$etag, id = x$id)
    })

    resdf <- rbind(resdf, do.call(rbind, simple_res))
  }

  resdf
}

