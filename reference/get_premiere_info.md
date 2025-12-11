# Get video premiere information

Checks if videos are premieres and gets premiere scheduling information.

## Usage

``` r
get_premiere_info(video_id, simplify = TRUE, auth = "key", ...)
```

## Arguments

- video_id:

  Video ID or vector of video IDs

- simplify:

  Whether to return simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame with premiere information

## Examples

``` r
if (FALSE) { # \dontrun{
# Check if video is a premiere
premiere_info <- get_premiere_info("dQw4w9WgXcQ")

# Check multiple videos for premiere status
premieres <- get_premiere_info(c("video1", "video2", "video3"))
} # }
```
