# Post a Top-Level Comment

Posts a new top-level comment on a YouTube video or channel. Requires
OAuth 2.0 authentication.

## Usage

``` r
post_comment(video_id = NULL, channel_id = NULL, text, ...)
```

## Arguments

- video_id:

  Character. ID of the video to comment on. Either \`video_id\` or
  \`channel_id\` must be provided.

- channel_id:

  Character. ID of the channel to comment on.

- text:

  Character. The text of the comment.

- ...:

  Additional arguments passed to
  [`tuber_POST_json`](https://gojiplus.github.io/tuber/reference/tuber_POST_json.md).

## Value

A list containing the API response.

## References

<https://developers.google.com/youtube/v3/docs/commentThreads/insert>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

post_comment(video_id = "yJXTXN4xrI8", text = "Great video!")
} # }
```
