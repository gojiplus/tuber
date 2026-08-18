# List Comment Threads

Retrieves comment threads using one explicit YouTube filter.

## Usage

``` r
list_comment_threads(
  video_id = NULL,
  channel_id = NULL,
  thread_ids = NULL,
  all_threads_for_channel_id = NULL,
  part = c("id", "snippet"),
  text_format = "html",
  max_results = 100,
  page_token = NULL,
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- video_id:

  Optional video ID.

- channel_id:

  Optional channel ID.

- thread_ids:

  Optional character vector of comment-thread IDs.

- all_threads_for_channel_id:

  Optional channel ID for all threads related to that channel.

- part:

  Character vector of comment-thread resource parts.

- text_format:

  Comment text format, \`"html"\` or \`"plainText"\`.

- max_results:

  Maximum total number of threads to return.

- page_token:

  Optional page token at which to start.

- simplify:

  If \`TRUE\`, return one row per top-level comment; otherwise return
  the raw API response with all collected items.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a comment-threads
response.

## References

<https://developers.google.com/youtube/v3/docs/commentThreads/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_comment_threads(video_id = "N708P-A45D0", max_results = 200)
} # }
```
