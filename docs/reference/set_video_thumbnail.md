# Set Video Thumbnail

Uploads a custom video thumbnail to YouTube and sets it for a video.
Requires OAuth 2.0 authentication.

## Usage

``` r
set_video_thumbnail(video_id, file, ...)
```

## Arguments

- video_id:

  Character. ID of the video to set the thumbnail for.

- file:

  Character. Path to the thumbnail image file (JPG or PNG, max 2MB).

- ...:

  Additional arguments passed to
  [`POST`](https://httr.r-lib.org/reference/POST.html).

## Value

A list containing the response from the API.

## References

<https://developers.google.com/youtube/v3/docs/thumbnails/set>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

set_video_thumbnail(video_id = "yJXTXN4xrI8", file = "thumbnail.jpg")
} # }
```
