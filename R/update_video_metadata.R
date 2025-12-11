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
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
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

update_video_metadata <- function(video_id, title, category_id, description, privacy_status, made_for_kids, auth = "token") {
  # Modern validation using checkmate
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")
  assert_character(title, len = 1, min.chars = 1, .var.name = "title")
  assert_character(category_id, len = 1, min.chars = 1, .var.name = "category_id")
  assert_character(description, len = 1, .var.name = "description")
  assert_choice(privacy_status, c("public", "private", "unlisted"), .var.name = "privacy_status")
  assert_logical(made_for_kids, len = 1, .var.name = "made_for_kids")
  assert_choice(auth, c("token", "key"), .var.name = "auth")

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

  query <- list(part = "snippet,status")

  # Use the centralized tuber_PUT function
  res <- tuber_PUT("videos", query = query, body = body, auth = auth)

  return(res)
}

# Example usage:
# update_video_metadata(video_id = "YourVideoID", title = "New Video Title", category_id = "24", description = "New Description", privacy_status = "public", made_for_kids = FALSE)
