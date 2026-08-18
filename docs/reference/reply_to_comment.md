# Reply to a Comment

Replies to an existing comment. Requires OAuth 2.0 authentication.

## Usage

``` r
reply_to_comment(parent_id, text, ...)
```

## Arguments

- parent_id:

  Character. The ID of the comment being replied to.

- text:

  Character. The text of the reply.

- ...:

  Additional arguments passed to
  [`tuber_POST_json`](https://gojiplus.github.io/tuber/reference/tuber_POST_json.md).

## Value

A list containing the API response.

## References

<https://developers.google.com/youtube/v3/docs/comments/insert>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

reply_to_comment(parent_id = "Ugz...", text = "Thanks for watching!")
} # }
```
