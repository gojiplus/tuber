# Get statistics on all the videos in a Channel

Efficiently collects all video IDs from a channel's uploads playlist,
then fetches statistics and details using batch processing for optimal
API quota usage.

## Usage

``` r
get_all_channel_video_stats(channel_id = NULL, mine = FALSE, ...)
```

## Arguments

- channel_id:

  Character. Id of the channel

- mine:

  Boolean. TRUE if you want to fetch stats of your own channel. Default
  is FALSE.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

A `data.frame` containing video metadata along with view, like, dislike
and comment counts.

If the `channel_id` is mistyped or there is no information, an empty
list is returned

## References

<https://developers.google.com/youtube/v3/docs/channels/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_all_channel_video_stats(channel_id="UCxOhDvtaoXDAB336AolWs3A")
get_all_channel_video_stats(channel_id="UCMtFAi84ehTSYSE9Xo") # Incorrect channel ID
} # }
```
