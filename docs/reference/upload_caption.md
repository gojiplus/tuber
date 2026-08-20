# Upload a Caption Track

Uploads a timed caption file using YouTube's resumable media-upload
protocol. The request requires OAuth 2.0 authorization.

## Usage

``` r
upload_caption(
  file,
  video_id,
  caption_name,
  language = "en-US",
  is_draft = FALSE,
  on_behalf_of_content_owner = NULL,
  open_url = FALSE,
  chunk_size = 8 * 1024^2,
  max_tries = 5,
  ...
)
```

## Arguments

- file:

  Path to a caption file containing timing information.

- video_id:

  YouTube video ID.

- caption_name:

  Name of the caption track. YouTube limits names to 150 characters.

- language:

  BCP 47 language tag for the caption track.

- is_draft:

  Whether the caption track should remain a draft.

- on_behalf_of_content_owner:

  Optional YouTube content-owner ID. This is only available to
  authorized YouTube content partners.

- open_url:

  Whether to open the video's YouTube URL after a successful upload.

- chunk_size:

  Bytes sent per request. Must be a multiple of 256 KB. Uploads resume
  from the last byte YouTube confirms, so a smaller chunk loses less
  work when a connection drops.

- max_tries:

  Consecutive failed attempts to tolerate before giving up.

- ...:

  Ignored; retained for backward compatibility.

## Value

A list containing the final HTTP response, parsed caption resource, and
video URL.

## References

\<https://developers.google.com/youtube/v3/docs/captions/insert\>

## Examples

``` r
if (FALSE) { # \dontrun{
upload_caption(
  file = "captions.vtt",
  video_id = "dQw4w9WgXcQ",
  caption_name = "English"
)
} # }
```
