# List Captions of a Video

List Captions of a Video

## Usage

``` r
list_caption_tracks(
  part = "snippet",
  video_id = NULL,
  lang = "en",
  id = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- part:

  Caption resource requested. Required. Comma separated list of one or
  more of the following: `id, snippet`. e.g., "id, snippet", "id"
  Default: `snippet`.

- video_id:

  ID of the video whose captions are requested. Required. No default.

- lang:

  Language of the caption; required; default is English ("en")

- id:

  comma-separated list of IDs that identify the caption resources that
  should be retrieved; optional; string

- simplify:

  Boolean. Default is TRUE. When TRUE, and part is `snippet`, a
  data.frame is returned

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

list of caption tracks. When `simplify` is `TRUE`, a `data.frame` is
returned with following columns:
`videoId, lastUpdated, trackKind, language, name, audioTrackType, isCC, isLarge, isEasyReader, isDraft, isAutoSynced, status, id`
(caption id)

## References

<https://developers.google.com/youtube/v3/docs/captions/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_caption_tracks(video_id = "yJXTXN4xrI8")
} # }
```
