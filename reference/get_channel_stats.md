# Get statistics of a Channel

Get statistics of a Channel

## Usage

``` r
get_channel_stats(channel_id = NULL, mine = NULL, batch_size = 50, ...)

list_my_channel(...)
```

## Arguments

- channel_id:

  Character. Id of the channel

- mine:

  Boolean. TRUE if you want to fetch stats of your own channel. Default
  is NULL.

- batch_size:

  Integer. When multiple channel IDs are provided, controls batch size
  for efficient processing. Default is 50.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

nested named list with top element names:
`kind, etag, id, snippet (list of details of the channel including title), statistics (list of 5)`

If the `channel_id` is mistyped or there is no information, an empty
list is returned

## References

<https://developers.google.com/youtube/v3/docs/channels/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_channel_stats(channel_id="UCMtFAi84ehTSYSE9XoHefig")
get_channel_stats(channel_id="UCMtFAi84ehTSYSE9Xo") # Incorrect channel ID
} # }
```
