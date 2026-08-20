# Update Video Metadata

Updates selected mutable video fields while preserving the other fields
in each requested YouTube resource part. At least one field must be
supplied.

## Usage

``` r
update_video_metadata(
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
)
```

## Arguments

- video_id:

  YouTube video ID.

- title:

  Optional title.

- category_id:

  Optional video-category ID.

- description:

  Optional description. Use \`""\` to clear it.

- tags:

  Optional character vector of tags. Use \`character()\` to clear
  existing tags.

- default_language:

  Optional default language.

- privacy_status:

  Optional privacy status: \`"private"\`, \`"public"\`, or
  \`"unlisted"\`.

- made_for_kids:

  Optional self-declared made-for-kids setting.

- contains_synthetic_media:

  Optional synthetic-media disclosure.

- embeddable:

  Optional embeddable setting.

- license:

  Optional license, \`"creativeCommon"\` or \`"youtube"\`.

- public_stats_viewable:

  Optional public-statistics setting.

- publish_at:

  Optional RFC 3339 publication time. YouTube requires a private video
  that has never been published.

- on_behalf_of_content_owner:

  Optional YouTube content-owner ID. This is only available to
  authorized YouTube content partners.

- ...:

  Additional arguments passed to \[get_video_details()\] and
  \[tuber_PUT()\].

## Value

The updated video resource.

## References

\<https://developers.google.com/youtube/v3/docs/videos/update\>

## Examples

``` r
if (FALSE) { # \dontrun{
update_video_metadata(
  video_id = "VIDEO_ID",
  title = "New Video Title",
  privacy_status = "unlisted"
)
} # }
```
