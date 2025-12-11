# Upload Video Caption to Youtube

Upload Video Caption to Youtube

## Usage

``` r
upload_caption(
  file,
  video_id,
  language = "en-US",
  caption_name,
  is_draft = FALSE,
  query = NULL,
  open_url = FALSE,
  ...
)
```

## Arguments

- file:

  Filename of the caption file with timing information (e.g., \`.srt\`,
  \`.vtt\`). As of April 12, 2024, timing information is required for
  all caption uploads.

- video_id:

  YouTube Video ID. Try
  [`list_my_videos`](https://gojiplus.github.io/tuber/reference/list_my_videos.md)
  for examples.

- language:

  character string of \`BCP47\` language type. See
  <https://www.rfc-editor.org/rfc/bcp/bcp47.txt> for language
  specification

- caption_name:

  character vector of the name for the caption.

- is_draft:

  logical indicating whether the caption track is a draft.

- query:

  Fields for \`query\` in \`POST\`

- open_url:

  Should the video be opened using
  [`browseURL`](https://rdrr.io/r/utils/browseURL.html)

- ...:

  Additional arguments to send to
  [`POST`](https://httr.r-lib.org/reference/POST.html)

## Value

A list of the response object from the
[`POST`](https://httr.r-lib.org/reference/POST.html), content, and the
URL of the video

## Note

See <https://developers.google.com/youtube/v3/docs/captions#resource>
for full specification

## Examples

``` r
if (FALSE) { # \dontrun{
xx = list_my_videos()
video_id = xx$contentDetails.videoId[1]
video_id = as.character(video_id)
language = "en-US"
} # }
```
