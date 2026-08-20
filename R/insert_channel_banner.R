#' Insert Channel Banner
#'
#' Uploads a channel banner image to YouTube.
#' The image must be a JPEG or PNG. The maximum file size is 6 MB.
#' This returns a URL that you can then use with `update_channel` (if implemented)
#' or through the standard API to set the channel banner.
#'
#' @param file Character. Path to the banner image file.
#' @param on_behalf_of_content_owner Optional YouTube content-owner ID. This is
#'   only available to authorized YouTube content partners.
#' @param \dots Ignored; retained for backward compatibility.
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
insert_channel_banner <- function(file, on_behalf_of_content_owner = NULL, ...) {
  # Validation
  assert_character(file, len = 1, min.chars = 1, .var.name = "file")
  if (!is.null(on_behalf_of_content_owner)) {
    assert_character(
      on_behalf_of_content_owner,
      len = 1,
      min.chars = 1,
      .var.name = "on_behalf_of_content_owner"
    )
  }

  if (!file.exists(file)) {
    abort("File does not exist",
      file_path = file,
      class = "tuber_file_not_found"
    )
  }

  file_size <- file.info(file)$size
  if (file_size > 6 * 1024 * 1024) {
    abort(
      "Banner file exceeds YouTube's 6 MB limit",
      file_path = file,
      class = "tuber_file_too_large"
    )
  }

  yt_check_token()
  track_quota_usage("channelBanners", "insert")

  query <- list(uploadType = "media")
  if (!is.null(on_behalf_of_content_owner)) {
    query$onBehalfOfContentOwner <- on_behalf_of_content_owner
  }

  req <- tuber_request(
    "channelBanners/insert",
    query = query,
    prefix = "upload/youtube/v3"
  ) |>
    req_method("POST") |>
    req_body_file(file, type = guess_type(file, empty = "application/octet-stream"))

  resp <- tuber_perform(req)
  list(request = resp, content = tuber_json(resp))
}
