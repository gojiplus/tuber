# Get Playlists

Get Playlists

## Usage

``` r
get_playlists(
  filter = NULL,
  part = "snippet",
  max_results = 50,
  hl = NULL,
  page_token = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `channel_id`: ID of the channel `playlist_id`:
  YouTube playlist ID.

- part:

  Required. One of the following:
  `contentDetails, id, localizations, player, snippet, status`. Default:
  `contentDetails`.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Default is 50. Values over 50 trigger additional requests and may
  increase API quota usage.

- hl:

  Language used for text values. Optional. Default is `en-US`. For other
  allowed language codes, see
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md).

- page_token:

  specific page in the result set that should be returned, optional

- simplify:

  Data Type: Boolean. Default is `TRUE`. If `TRUE` and if part requested
  is `contentDetails`, the function returns a `data.frame`. Else a list
  with all the information returned.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

playlists When `simplify` is `TRUE`, a `data.frame` with 4 columns is
returned: `kind, etag, id, contentDetails.itemCount`

## References

<https://developers.google.com/youtube/v3/docs/playlists/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_playlists(filter=c(channel_id="UCMtFAi84ehTSYSE9XoHefig"))
get_playlists(filter=c(channel_id="UCMtFAi84ehTSYSE9X")) # incorrect Channel ID

# For searching playlists by keyword, use yt_search() instead:
# yt_search(term="tutorial", channel_id="UCMtFAi84ehTSYSE9XoHefig", type="playlist")
} # }
```
