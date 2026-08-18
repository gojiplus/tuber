# List Playlists

Retrieves playlists by channel, playlist ID, or authenticated ownership.

## Usage

``` r
list_playlists(
  channel_id = NULL,
  playlist_ids = NULL,
  mine = FALSE,
  part = c("snippet", "contentDetails", "status"),
  max_results = 50,
  language = NULL,
  page_token = NULL,
  simplify = TRUE,
  auth = if (mine) "token" else "key",
  ...
)
```

## Arguments

- channel_id:

  Optional channel ID.

- playlist_ids:

  Optional character vector of playlist IDs.

- mine:

  If \`TRUE\`, retrieve playlists owned by the authenticated user.

- part:

  Character vector of playlist resource parts.

- max_results:

  Maximum total number of playlists to return.

- language:

  Optional language code for localized text.

- page_token:

  Optional page token at which to start.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw API
  response with all collected items.

- auth:

  Authentication method, \`"key"\` or \`"token"\`. \`mine = TRUE\`
  requires OAuth.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a playlists-list
response.

## References

<https://developers.google.com/youtube/v3/docs/playlists/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_playlists(channel_id = "UCMtFAi84ehTSYSE9XoHefig")
list_playlists(playlist_ids = c("PLAYLIST_1", "PLAYLIST_2"))
list_playlists(mine = TRUE)
} # }
```
