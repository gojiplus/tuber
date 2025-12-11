# Update a YouTube Video's Metadata

This function updates the metadata of an existing YouTube video using
the YouTube Data API.

## Usage

``` r
update_video_metadata(
  video_id,
  title,
  category_id,
  description,
  privacy_status,
  made_for_kids,
  auth = "token"
)
```

## Arguments

- video_id:

  A character string specifying the ID of the video you want to update.

- title:

  A character string specifying the new title for the video.

- category_id:

  A character string specifying the new category ID for the video.

- description:

  A character string specifying the new description for the video.

- privacy_status:

  A character string specifying the new privacy status for the video
  ('public', 'private', or 'unlisted').

- made_for_kids:

  A boolean specifying whether the video is self-declared as made for
  kids.

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

## Value

A list containing the server response after the update attempt.

## Examples

``` r
if (FALSE) { # \dontrun{
update_video_metadata(video_id = "YourVideoID",
                      title = "New Video Title",
                      category_id = "24",
                      description = "New Description",
                      privacy_status = "public",
                      made_for_kids = FALSE)
} # }
```
