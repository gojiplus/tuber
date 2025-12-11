# Get video thumbnails information

Retrieves thumbnail URLs and metadata for videos.

## Usage

``` r
get_video_thumbnails(video_id, size = NULL, simplify = TRUE, auth = "key", ...)
```

## Arguments

- video_id:

  Video ID or vector of video IDs

- size:

  Thumbnail size: "default", "medium", "high", "standard", "maxres"

- simplify:

  Whether to return a simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame with thumbnail information

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all thumbnail sizes for a video
thumbs <- get_video_thumbnails("dQw4w9WgXcQ")

# Get only high resolution thumbnails
thumbs_hd <- get_video_thumbnails("dQw4w9WgXcQ", size = "high")

# Get thumbnails for multiple videos
thumbs_batch <- get_video_thumbnails(c("dQw4w9WgXcQ", "M7FIvfx5J10"))
} # }
```
