# Get Video Statistics

Retrieves statistics for one or more videos and always returns one row
per video found.

## Usage

``` r
get_video_stats(
  video_ids,
  include_content_details = FALSE,
  batch_size = 50,
  auth = "key",
  ...
)
```

## Arguments

- video_ids:

  Character vector of YouTube video IDs.

- include_content_details:

  Include duration, definition, dimension, licensed-content, and
  projection fields.

- batch_size:

  Number of video IDs per API request, up to 50.

- auth:

  Authentication method, \`"token"\` or \`"key"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame with snake-case column names and one row per video. Count
columns are numeric and missing statistics are returned as \`NA\`.

## References

<https://developers.google.com/youtube/v3/docs/videos/list>

## Examples

``` r
if (FALSE) { # \dontrun{
get_video_stats("N708P-A45D0")
get_video_stats(c("N708P-A45D0", "M7FIvfx5J10"), auth = "key")
} # }
```
