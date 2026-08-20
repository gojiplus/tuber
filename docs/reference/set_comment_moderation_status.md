# Set Comment Moderation Status

Sets the moderation status of one or more comments. Requires OAuth 2.0
authentication and owner privileges.

## Usage

``` r
set_comment_moderation_status(
  comment_id,
  moderation_status,
  ban_author = FALSE,
  ...
)
```

## Arguments

- comment_id:

  Character vector. The IDs of the comments to update.

- moderation_status:

  Character. Valid values are 'heldForReview', 'published', 'rejected'.

- ban_author:

  Logical. Whether to ban the author from commenting on the channel.
  Optional.

- ...:

  Additional arguments passed to
  [`tuber_POST_json`](https://gojiplus.github.io/tuber/reference/tuber_POST_json.md).

## Value

A list containing the API response.

## References

<https://developers.google.com/youtube/v3/docs/comments/setModerationStatus>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

set_comment_moderation_status(comment_id = "Ugz...", moderation_status = "rejected")
} # }
```
