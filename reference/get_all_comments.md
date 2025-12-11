# Get all the comments for a video including replies

Get all the comments for a video including replies

## Usage

``` r
get_all_comments(video_id = NULL, ...)
```

## Arguments

- video_id:

  string; Required. `video_id`: video ID.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

a `data.frame` with the following columns:
`authorDisplayName, authorProfileImageUrl, authorChannelUrl,`
` authorChannelId.value, videoId, textDisplay, canRate, viewerRating, likeCount, publishedAt, updatedAt, id, moderationStatus, parentId`

## References

<https://developers.google.com/youtube/v3/docs/commentThreads/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_all_comments(video_id = "a-UQz7fqR3w")
} # }
```
