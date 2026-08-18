# List Caption Tracks

Lists caption-track metadata for a video. The caption text itself is
returned by \[download_caption()\]. YouTube requires OAuth authorization
for this method.

## Usage

``` r
list_captions(
  video_id,
  caption_ids = NULL,
  part = "snippet",
  simplify = TRUE,
  ...
)
```

## Arguments

- video_id:

  YouTube video ID.

- caption_ids:

  Optional character vector of caption-track IDs to select.

- part:

  Character vector of caption resource parts.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw API
  response.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a caption-list
response.

## References

<https://developers.google.com/youtube/v3/docs/captions/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_captions(video_id = "M7FIvfx5J10")
} # }
```
