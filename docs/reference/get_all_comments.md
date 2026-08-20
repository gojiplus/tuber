# Get All Video Comments, Including Replies

Retrieves top-level comments and, when a thread response contains only a
reply preview, follows \`comments.list\` pagination to retrieve the
remaining replies.

## Usage

``` r
get_all_comments(video_id, max_results = NULL, auth = "key", ...)
```

## Arguments

- video_id:

  Video ID.

- max_results:

  Optional maximum total number of comments and replies. \`NULL\`
  retrieves all available comments.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame with one row per top-level comment or reply and snake-case
column names.

## References

<https://developers.google.com/youtube/v3/docs/commentThreads/list>
<https://developers.google.com/youtube/v3/docs/comments/list>

## Examples

``` r
if (FALSE) { # \dontrun{
get_all_comments("a-UQz7fqR3w", max_results = 100)
} # }
```
