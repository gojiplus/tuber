#' Delete Channel Sections
#'
#' Delete a Channel Section
#'
#' @param id Required. ID of the channel section.
#' @param \dots Additional arguments passed to \code{\link{tuber_DELETE}}.
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channelSections/delete}
#' @examples
#'
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' delete_channel_sections(c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA"))
#' }

delete_channel_sections <- function(id = NULL, ...) {

  # Modern validation using checkmate
  assert_character(id, len = 1, min.chars = 1, .var.name = "id")

  querylist <- list(id = id)

  res <- tuber_DELETE("channelSections", querylist, ...)

  res
}
