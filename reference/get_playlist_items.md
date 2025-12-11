# Get Playlist Items

Get Playlist Items

## Usage

``` r
get_playlist_items(
  filter = NULL,
  part = "contentDetails",
  max_results = 50,
  video_id = NULL,
  page_token = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `item_id`: comma-separated list of one or more
  unique playlist item IDs. `playlist_id`: YouTube playlist ID.

- part:

  Required. Comma separated string including one or more of the
  following: `contentDetails, id, snippet, status`. Default:
  `contentDetails`.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Default is 50. If over 50, additional requests are made until the
  requested amount is retrieved. Larger values may increase API quota
  usage.

- video_id:

  Optional. request should return only the playlist items that contain
  the specified video.

- page_token:

  specific page in the result set that should be returned, optional

- simplify:

  returns a data.frame rather than a list.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

playlist items

## References

<https://developers.google.com/youtube/v3/docs/playlistItems/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_playlist_items(filter =
                       c(playlist_id = "PLrEnWoR732-CN09YykVof2lxdI3MLOZda"))
get_playlist_items(filter =
                       c(playlist_id = "PL0fOlXVeVW9QMO3GoESky4yDgQfK2SsXN"),
                       max_results = 51)
} # }
```
