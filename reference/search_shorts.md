# Search for shorts (YouTube Shorts)

Search specifically for YouTube Shorts videos.

## Usage

``` r
search_shorts(
  query,
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

- query:

  Search query

- max_results:

  Maximum number of results (1-50)

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

  Additional arguments passed to tuber_GET

## Value

List or data frame with search results for shorts

## Examples

``` r
if (FALSE) { # \dontrun{
# Search for recent shorts about cats
shorts <- search_shorts("cats", max_results = 25, order = "date")

# Search for popular shorts in a specific region
shorts_us <- search_shorts("music", region_code = "US", order = "viewCount")
} # }
```
