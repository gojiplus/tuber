# Get Playlist Item Video IDs

Get Playlist Item Video IDs

## Usage

``` r
get_playlist_item_videoids(
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
  Default is 50. Values over 50 trigger multiple requests and may
  increase API quota usage.

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

<https://developers.google.com/youtube/v3/docs/playlists/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_playlist_items(filter =
                       c(playlist_id = "YourPlaylistID"))
get_playlist_items(filter =
                       c(playlist_id = "YourPlaylistID"),
                       max_results = 51)
} # }
```
