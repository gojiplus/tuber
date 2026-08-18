# List Most-Popular Videos

Retrieves the \`mostPopular\` videos chart.

## Usage

``` r
list_popular_videos(
  region_code = NULL,
  category_id = NULL,
  max_results = 50,
  part = c("snippet", "statistics"),
  language = NULL,
  page_token = NULL,
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- region_code:

  Optional ISO 3166-1 alpha-2 content-region code.

- category_id:

  Optional video-category ID.

- max_results:

  Maximum total number of videos to return.

- part:

  Character vector of video resource parts.

- language:

  Optional language code for localized text.

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

A data frame when \`simplify = TRUE\`; otherwise a videos-list response.

## References

<https://developers.google.com/youtube/v3/docs/videos/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_popular_videos(region_code = "US", max_results = 10)
} # }
```
