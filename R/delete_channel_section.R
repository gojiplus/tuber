#' Delete a Channel Section
#'
#' @param section_id Channel-section ID.
#' @param ... Additional arguments passed to [tuber_DELETE()].
#' @return The empty API response, invisibly.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channelSections/delete}
#' @examples
#' \dontrun{
#' delete_channel_section("SECTION_ID")
#' }
delete_channel_section <- function(section_id, ...) {
  assert_string(section_id, min.chars = 1, .var.name = "section_id")
  tuber_DELETE("channelSections", query = list(id = section_id), ...)
}
