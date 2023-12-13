#' Update a YouTube Video's Metadata
#'
#' This function updates the metadata of an existing YouTube video using the YouTube Data API.
#'
#' @param video_id A character string specifying the ID of the video you want to update.
#' @param title A character string specifying the new title for the video.
#' @param category_id A character string specifying the new category ID for the video.
#' @param description A character string specifying the new description for the video.
#' @param privacy_status A character string specifying the new privacy status for the video ('public', 'private', or 'unlisted').
#' @param made_for_kids A boolean specifying whether the video is self-declared as made for kids.
#'
#' @return A list containing the server response after the update attempt.
#' @export
#'
#' @examples
#' \dontrun{
#' update_video_metadata(video_id = "YourVideoID",
#'                       title = "New Video Title",
#'                       category_id = "24",
#'                       description = "New Description",
#'                       privacy_status = "public",
#'                       made_for_kids = FALSE)
#' }

update_video_metadata <- function(video_id, title, category_id, description, privacy_status, made_for_kids) {
  # Check for a valid token
  yt_check_token()

  # Define the body for the PUT request
  body <- list(
    id = video_id,
    snippet = list(
      title = title,
      categoryId = category_id,
      description = description
    ),
    status = list(
      privacyStatus = privacy_status,
      selfDeclaredMadeForKids = made_for_kids
    )
  )

  body_json <- jsonlite::toJSON(body, auto_unbox = TRUE)

  # Use the existing tuber infrastructure to send the PUT request
  req <- httr::PUT(
    url = "https://www.googleapis.com/youtube/v3/videos",
    query = list(key = getOption("google_key"), part = "snippet,status"),
    config = httr::config(token = getOption("google_token")),
    body = body_json,
    httr::add_headers(
      `Accept` = "application/json",
      `Content-Type` = "application/json"
    )
  )

  # Check for errors
  tuber_check(req)

  # Extract and return the content
  return(httr::content(req))
}

# Example usage:
# update_video_metadata(video_id = "YourVideoID", title = "New Video Title", category_id = "24", description = "New Description", privacy_status = "public", made_for_kids = FALSE)
