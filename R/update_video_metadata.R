#' Update Video Metadata
#'
#' Updates selected mutable video fields while preserving the other fields in
#' each requested YouTube resource part. At least one field must be supplied.
#'
#' @param video_id YouTube video ID.
#' @param title Optional title.
#' @param category_id Optional video-category ID.
#' @param description Optional description. Use `""` to clear it.
#' @param tags Optional character vector of tags. Use `character()` to clear
#'   existing tags.
#' @param default_language Optional default language.
#' @param privacy_status Optional privacy status: `"private"`, `"public"`, or
#'   `"unlisted"`.
#' @param made_for_kids Optional self-declared made-for-kids setting.
#' @param contains_synthetic_media Optional synthetic-media disclosure.
#' @param embeddable Optional embeddable setting.
#' @param license Optional license, `"creativeCommon"` or `"youtube"`.
#' @param public_stats_viewable Optional public-statistics setting.
#' @param publish_at Optional RFC 3339 publication time. YouTube requires a
#'   private video that has never been published.
#' @param on_behalf_of_content_owner Optional YouTube content-owner ID. This is
#'   only available to authorized YouTube content partners.
#' @param ... Additional arguments passed to [get_video_details()] and
#'   [tuber_PUT()].
#'
#' @return The updated video resource.
#' @export
#' @references
#' <https://developers.google.com/youtube/v3/docs/videos/update>
#' @examples
#' \dontrun{
#' update_video_metadata(
#'   video_id = "VIDEO_ID",
#'   title = "New Video Title",
#'   privacy_status = "unlisted"
#' )
#' }
update_video_metadata <- function(
  video_id,
  title = NULL,
  category_id = NULL,
  description = NULL,
  tags = NULL,
  default_language = NULL,
  privacy_status = NULL,
  made_for_kids = NULL,
  contains_synthetic_media = NULL,
  embeddable = NULL,
  license = NULL,
  public_stats_viewable = NULL,
  publish_at = NULL,
  on_behalf_of_content_owner = NULL,
  ...
) {
  assert_string(video_id, min.chars = 1, .var.name = "video_id")
  if (!is.null(title)) assert_string(title, min.chars = 1, .var.name = "title")
  if (!is.null(category_id)) {
    assert_string(category_id, min.chars = 1, .var.name = "category_id")
  }
  if (!is.null(description)) assert_string(description, .var.name = "description")
  if (!is.null(tags)) {
    assert_character(tags, any.missing = FALSE, .var.name = "tags")
  }
  if (!is.null(default_language)) {
    assert_string(default_language, min.chars = 1, .var.name = "default_language")
  }
  if (!is.null(privacy_status)) {
    assert_choice(
      privacy_status,
      c("private", "public", "unlisted"),
      .var.name = "privacy_status"
    )
  }
  logical_updates <- list(
    made_for_kids = made_for_kids,
    contains_synthetic_media = contains_synthetic_media,
    embeddable = embeddable,
    public_stats_viewable = public_stats_viewable
  )
  for (field in names(logical_updates)) {
    if (!is.null(logical_updates[[field]])) {
      assert_flag(logical_updates[[field]], .var.name = field)
    }
  }
  if (!is.null(license)) {
    assert_choice(license, c("creativeCommon", "youtube"), .var.name = "license")
  }
  if (!is.null(publish_at)) validate_rfc3339_date(publish_at, "publish_at")
  if (!is.null(on_behalf_of_content_owner)) {
    assert_string(
      on_behalf_of_content_owner,
      min.chars = 1,
      .var.name = "on_behalf_of_content_owner"
    )
  }

  snippet_updates <- list(
    title = title,
    categoryId = category_id,
    description = description,
    tags = tags,
    defaultLanguage = default_language
  )
  status_updates <- list(
    privacyStatus = privacy_status,
    selfDeclaredMadeForKids = made_for_kids,
    containsSyntheticMedia = contains_synthetic_media,
    embeddable = embeddable,
    license = license,
    publicStatsViewable = public_stats_viewable,
    publishAt = publish_at
  )
  snippet_updates <- Filter(Negate(is.null), snippet_updates)
  status_updates <- Filter(Negate(is.null), status_updates)
  parts <- c(
    if (length(snippet_updates) > 0) "snippet",
    if (length(status_updates) > 0) "status"
  )
  if (length(parts) == 0) {
    abort(
      "Supply at least one video metadata field to update.",
      class = "tuber_missing_update"
    )
  }

  current <- get_video_details(
    video_ids = video_id,
    part = parts,
    simplify = FALSE,
    auth = "token",
    ...
  )
  if (length(current$items %||% list()) == 0) {
    abort(
      "Video was not found or is not accessible.",
      video_id = video_id,
      class = "tuber_video_not_found"
    )
  }
  item <- current$items[[1]]
  body <- list(id = video_id)

  if ("snippet" %in% parts) {
    mutable_snippet <- c("title", "description", "tags", "categoryId", "defaultLanguage")
    snippet <- (item$snippet %||% list())[mutable_snippet]
    snippet <- snippet[!vapply(snippet, is.null, logical(1))]
    body$snippet <- modifyList(snippet, snippet_updates)
  }
  if ("status" %in% parts) {
    mutable_status <- c(
      "embeddable",
      "license",
      "privacyStatus",
      "publicStatsViewable",
      "publishAt",
      "selfDeclaredMadeForKids",
      "containsSyntheticMedia"
    )
    status <- (item$status %||% list())[mutable_status]
    status <- status[!vapply(status, is.null, logical(1))]
    body$status <- modifyList(status, status_updates)
  }

  query <- list(part = paste(parts, collapse = ","))
  if (!is.null(on_behalf_of_content_owner)) {
    query$onBehalfOfContentOwner <- on_behalf_of_content_owner
  }
  tuber_PUT("videos", query = query, body = body, ...)
}
