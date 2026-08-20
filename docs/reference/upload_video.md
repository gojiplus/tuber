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

- ...:

  Additional arguments to send to
  [`tuber_POST`](https://gojiplus.github.io/tuber/reference/tuber_POST.md)
  and therefore [`POST`](https://httr.r-lib.org/reference/POST.html)

## Value

A list of the response object from the
[`POST`](https://httr.r-lib.org/reference/POST.html), content, and the
URL of the uploaded

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
