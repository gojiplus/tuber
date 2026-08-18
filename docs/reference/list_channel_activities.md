# List Channel Activities

List Channel Activities

## Usage

``` r
list_channel_activities(
  channel_id,
  part = c("snippet", "contentDetails"),
  max_results = 50,
  page_token = NULL,
  published_after = NULL,
  published_before = NULL,
  region_code = NULL,
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- channel_id:

  Channel ID.

- part:

  Character vector of activity resource parts.

- max_results:

  Maximum total number of activities to return.

- page_token:

  Optional page token at which to start.

- published_after:

  Optional RFC 3339 lower timestamp bound.

- published_before:

  Optional RFC 3339 upper timestamp bound.

- region_code:

  Optional ISO 3166-1 alpha-2 content-region code.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw API
  response with all collected items.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise an activities-list
response.

## References

<https://developers.google.com/youtube/v3/docs/activities/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_channel_activities("UCRw8bIz2wMLmfgAgWm903cA", max_results = 100)
} # }
```
