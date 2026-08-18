# List Playlist Items

Retrieves items from one playlist or retrieves specific playlist items
by their playlist-item IDs.

## Usage

``` r
list_playlist_items(
  playlist_id = NULL,
  playlist_item_ids = NULL,
  video_id = NULL,
  part = c("contentDetails", "snippet", "status"),
  max_results = 50,
  page_token = NULL,
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- playlist_id:

  Optional playlist ID.

- playlist_item_ids:

  Optional character vector of playlist-item IDs. Supply exactly one of
  \`playlist_id\` or \`playlist_item_ids\`.

- video_id:

  Optional video ID used to filter items in \`playlist_id\`.

- part:

  Character vector of playlist-item resource parts.

- max_results:

  Maximum total number of items to return.

- page_token:

  Optional page token at which to start.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw API
  response with all collected items.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a playlist-items
response.

## References

<https://developers.google.com/youtube/v3/docs/playlistItems/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_playlist_items(
  playlist_id = "PLrEnWoR732-CN09YykVof2lxdI3MLOZda",
  max_results = 100
)
} # }
```
