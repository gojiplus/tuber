# Get statistics of a Video or Videos

Gets view count, like count, comment count and other statistics for
YouTube video(s). For unlisted videos, you must use OAuth authentication
with the channel owner's credentials. Automatically uses batch
processing when multiple video IDs are provided for efficiency.

## Usage

``` r
get_stats(
  video_id = NULL,
  include_content_details = FALSE,
  batch_size = 50,
  simplify = TRUE,
  ...
)
```

## Arguments

- video_id:

  Character vector. One or more video IDs. Required.

- include_content_details:

  Boolean. Include contentDetails (duration, definition, etc.) in
  response. Default: FALSE.

- batch_size:

  Integer. Number of videos per API call when batching (max 50).
  Default: 50.

- simplify:

  Boolean. Return simplified data frame for multiple videos. Default:
  TRUE.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

For single video: list with elements
`id, viewCount, likeCount, dislikeCount, favoriteCount, commentCount`.
When `include_content_details = TRUE`, also includes
`duration, definition, dimension, licensedContent, projection`. For
multiple videos: data frame with one row per video (if simplify=TRUE) or
list of results.

## References

<https://developers.google.com/youtube/v3/docs/videos/list#parameters>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

# Single video
get_stats(video_id="N708P-A45D0")

# Multiple videos (automatic batching)
video_ids <- c("N708P-A45D0", "M7FIvfx5J10", "kJQP7kiw5Fk")
stats_df <- get_stats(video_ids)

# Include video duration and other content details:
get_stats(video_id="N708P-A45D0", include_content_details = TRUE)

# For unlisted videos, must authenticate as channel owner:
# yt_oauth("your_client_id", "your_client_secret")
# get_stats(video_id="your_unlisted_video_id")
} # }
```
