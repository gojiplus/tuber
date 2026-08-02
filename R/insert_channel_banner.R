#' Insert Channel Banner
#'
#' Uploads a channel banner image to YouTube.
#' The image must be a JPEG, PNG, or GIF. The maximum file size is 6MB.
#' This returns a URL that you can then use with `update_channel` (if implemented)
#' or through the standard API to set the channel banner.
#'
#' @param file Character. Path to the banner image file.
#' @param channel_id Character. Optional. The channel to upload the banner for (needed if using service accounts).
#' @param \dots Additional arguments passed to \code{\link[httr]{POST}}.
#'
#' @return A list containing the response from the API, including the `url` for the banner.
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/channelBanners/insert}
#'
#' @examples
#' \dontrun{
#' # Set API token via yt_oauth() first
#'
#' banner <- insert_channel_banner(file = "banner.jpg")
#' print(banner$content$url)
#' }
insert_channel_banner <- function(file, channel_id = NULL, ...) {
  # Validation
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")
  if (!is.null(channel_id)) {
    assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
  }

  if (!file.exists(file)) {
    abort("File does not exist",
          file_path = file,
          class = "tuber_file_not_found")
  }

  file_size <- file.info(file)$size
  if (file_size > 6 * 1024 * 1024) {
    warning("Banner file size exceeds 6MB. The upload may fail.")
  }

  yt_check_token()

  url <- "https://www.googleapis.com/upload/youtube/v3/channelBanners/insert"

  query <- list()
  if (!is.null(channel_id)) {
    query$onBehalfOfContentOwnerChannel <- channel_id
  }

  req <- httr::POST(
    url,
    query = query,
    body = httr::upload_file(file),
    config(token = getOption("google_token")),
    ...
  )

  tuber_check(req)

  res <- content(req)
  list(request = req, content = res)
}
