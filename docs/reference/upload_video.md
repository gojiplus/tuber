# Upload Video to Youtube

Upload Video to Youtube

## Usage

``` r
upload_video(
  file,
  snippet = NULL,
  status = list(privacyStatus = "public"),
  notify_subscribers = TRUE,
  on_behalf_of_content_owner = NULL,
  content_owner_channel_id = NULL,
  open_url = FALSE,
  chunk_size = 8 * 1024^2,
  max_tries = 5,
  ...
)
```

## Arguments

- file:

  Filename of the video locally

- snippet:

  Additional fields for the video, including \`description\` and
  \`title\`. See
  <https://developers.google.com/youtube/v3/docs/videos#resource> for
  other fields. Coerced to a JSON object

- status:

  Additional fields to be put into the `status` input. options for
  \`status\` are \`license\` (which should hold: \`creativeCommon\`, or
  \`youtube\`), \`privacyStatus\`, \`publicStatsViewable\`,
  \`publishAt\`.

- notify_subscribers:

  Whether YouTube should notify subscribers about the new video.

- on_behalf_of_content_owner:

  Optional YouTube content-owner ID. This is only available to
  authorized YouTube content partners.

- content_owner_channel_id:

  Optional channel ID for a content partner upload. This must be
  supplied with \`on_behalf_of_content_owner\`.

- open_url:

  Should the video be opened using
  [`browseURL`](https://rdrr.io/r/utils/browseURL.html)

- chunk_size:

  Bytes sent per request. Must be a multiple of 256 KB. Uploads resume
  from the last byte YouTube confirms, so a smaller chunk loses less
  work when a connection drops.

- max_tries:

  Consecutive failed attempts to tolerate before giving up.

- ...:

  Ignored; retained for backward compatibility.

## Value

A list of the response object, content, and the URL of the uploaded

## Note

The information for \`status\` and \`snippet\` are at
<https://developers.google.com/youtube/v3/docs/videos#resource> but the
subset of these fields to pass in are located at:
<https://developers.google.com/youtube/v3/docs/videos/insert> The
\`part“ parameter serves two purposes in this operation. It identifies
the properties that the write operation will set, this will be
automatically detected by the names of \`body\`. See
<https://developers.google.com/youtube/v3/docs/videos/insert#usage>

## Examples

``` r
if (FALSE) { # \dontrun{
snippet = list(
  title = "Test Video",
  description = "This is just a random test.",
  tags = c("r language", "r programming", "data analysis")
)
status = list(privacyStatus = "private")
} # }
```
