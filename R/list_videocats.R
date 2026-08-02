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

  querylist <- c(list(part = "snippet"), as.list(filter))

  res <- tuber_GET("videoCategories", querylist, ...)

  # Cat total results
  cat("Total Number of Categories:", length(res$items), "\n")

  # `filter` is a named character vector, so it must be indexed by name. A
  # category_id filter carries no region, which yields NA.
  region_code <- unname(filter["regionCode"])

  resdf <- data.frame(region_code = character(),
                      channelId = character(),
                      title = character(),
                      assignable = logical(),
                      etag = character(),
                      id = character(),
                      stringsAsFactors = FALSE)

  if (length(res$items) > 0) {
    simple_res <- lapply(res$items, function(x) {
      as.data.frame(t(c(unlist(x$snippet), etag = x$etag, id = x$id)),
                    stringsAsFactors = FALSE)
    })

    resdf <- bind_rows(simple_res)
    resdf$region_code <- region_code
    resdf <- resdf[, union("region_code", names(resdf)), drop = FALSE]
  }

  resdf
}

