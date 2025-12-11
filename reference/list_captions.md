# List Captions for YouTube Video

List Captions for YouTube Video

## Usage

``` r
list_captions(video_id, query = NULL, auth = "token", ...)
```

## Arguments

- video_id:

  ID of the YouTube video

- query:

  Fields for \`query\` in \`GET\`

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- ...:

  Additional arguments to send to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md)

## Value

A list containing caption information

## Examples

``` r
if (FALSE) { # \dontrun{
video_id <- "M7FIvfx5J10"
list_captions(video_id)
} # }
```
