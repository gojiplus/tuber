# Get Video IDs from a Playlist

Get Video IDs from a Playlist

## Usage

``` r
get_playlist_video_ids(
  playlist_id,
  max_results = 50,
  page_token = NULL,
  auth = "key",
  ...
)
```

## Arguments

- playlist_id:

  Playlist ID.

- max_results:

  Maximum total number of video IDs to return.

- page_token:

  Optional page token at which to start.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[list_playlist_items()\].

## Value

A character vector of video IDs.

## Examples

``` r
if (FALSE) { # \dontrun{
get_playlist_video_ids("PLrEnWoR732-CN09YykVof2lxdI3MLOZda")
} # }
```
