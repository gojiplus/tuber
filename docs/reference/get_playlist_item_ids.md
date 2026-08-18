# Get Playlist-Item IDs

Get Playlist-Item IDs

## Usage

``` r
get_playlist_item_ids(
  playlist_id = NULL,
  playlist_item_ids = NULL,
  video_id = NULL,
  max_results = 50,
  page_token = NULL,
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

- max_results:

  Maximum total number of items to return.

- page_token:

  Optional page token at which to start.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A character vector of playlist-item IDs.

## Examples

``` r
if (FALSE) { # \dontrun{
get_playlist_item_ids(playlist_id = "PLrEnWoR732-CN09YykVof2lxdI3MLOZda")
} # }
```
