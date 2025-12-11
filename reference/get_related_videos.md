# Get Related Videos

Takes a video id and returns related videos

## Usage

``` r
get_related_videos(
  video_id = NULL,
  max_results = 50,
  safe_search = "none",
  ...
)
```

## Arguments

- video_id:

  Character. Required. No default.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Default is 50. Values over 50 trigger multiple requests and may
  increase API quota usage.

- safe_search:

  Character. Optional. Takes one of three values: `'moderate'`, `'none'`
  (default) or `'strict'`

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

`data.frame` with 16 columns:
`video_id, rel_video_id, publishedAt, channelId, title, description, thumbnails.default.url, thumbnails.default.width, thumbnails.default.height, thumbnails.medium.url, thumbnails.medium.width, thumbnails.medium.height, thumbnails.high.url, thumbnails.high.width, thumbnails.high.height, channelTitle, liveBroadcastContent`

## References

<https://developers.google.com/youtube/v3/docs/search/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_related_videos(video_id = "yJXTXN4xrI8")
} # }
```
