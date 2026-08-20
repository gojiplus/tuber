# List My Videos

Lists videos in the authenticated channel's uploads playlist.

## Usage

``` r
list_my_videos(max_results = 50, page_token = NULL, simplify = TRUE, ...)
```

## Arguments

- max_results:

  Maximum total number of videos to return.

- page_token:

  Optional page token at which to start.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw
  playlist-items response.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a playlist-items
response.

## Examples

``` r
if (FALSE) { # \dontrun{
list_my_videos(max_results = 100)
} # }
```
