# Search for videos shorter than four minutes

Uses YouTube's \`videoDuration = "short"\` filter. This filter includes
every video shorter than four minutes and does not identify the YouTube
Shorts product.

## Usage

``` r
search_short_videos(
  term,
  max_results = 25,
  order = "relevance",
  region_code = NULL,
  published_after = NULL,
  published_before = NULL,
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- term:

  Search term.

- max_results:

  Maximum total number of results.

- order:

  Sort order: "date", "rating", "relevance", "title", "viewCount"

- region_code:

  Region code for search

- published_after:

  RFC 3339 formatted date-time (e.g., "2023-01-01T00:00:00Z")

- published_before:

  RFC 3339 formatted date-time

- simplify:

  Whether to return simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- ...:

  Additional arguments passed to \[yt_search()\].

## Value

List or data frame with search results for videos under four minutes

## Examples

``` r
if (FALSE) { # \dontrun{
# Search for recent shorts about cats
short_videos <- search_short_videos("cats", max_results = 25, order = "date")

# Search for popular short-duration videos in a specific region
short_videos_us <- search_short_videos(
  "music",
  region_code = "US",
  order = "viewCount"
)
} # }
```
