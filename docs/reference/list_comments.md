# List Comments or Replies

Retrieves specific comments by ID or replies to one parent comment.

## Usage

``` r
list_comments(
  comment_ids = NULL,
  parent_id = NULL,
  part = c("id", "snippet"),
  max_results = 100,
  text_format = "html",
  page_token = NULL,
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- comment_ids:

  Optional character vector of comment IDs.

- parent_id:

  Optional parent-comment ID. Supply exactly one of \`comment_ids\` or
  \`parent_id\`.

- part:

  Character vector of comment resource parts.

- max_results:

  Maximum total number of replies to return. Ignored when
  \`comment_ids\` is supplied.

- text_format:

  Comment text format, \`"html"\` or \`"plainText"\`.

- page_token:

  Optional page token at which to start.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw API
  response with all collected items.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a comments-list
response.

## References

<https://developers.google.com/youtube/v3/docs/comments/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_comments(comment_ids = "COMMENT_ID")
list_comments(parent_id = "PARENT_COMMENT_ID", max_results = 200)
} # }
```
