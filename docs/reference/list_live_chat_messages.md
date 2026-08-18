# List Live Chat Messages

Retrieves live chat messages for a specific live chat. Note that live
chat messages can only be retrieved for active live broadcasts.

## Usage

``` r
list_live_chat_messages(
  live_chat_id,
  part = "snippet,authorDetails",
  language = NULL,
  max_results = 500,
  page_token = NULL,
  profile_image_size = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- live_chat_id:

  Character. The id of the live chat.

- part:

  Character. Parts to retrieve. Valid values are "snippet",
  "authorDetails". Default is "snippet,authorDetails".

- language:

  Optional language code for localized text.

- max_results:

  Maximum total number of messages to return.

- page_token:

  Character. Specific page token to retrieve. Optional.

- profile_image_size:

  Integer. Size of the profile image to return. Optional.

- simplify:

  Logical. Whether to return a simplified data.frame. Default is TRUE.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

A data.frame or list of live chat messages.

## References

<https://developers.google.com/youtube/v3/live/docs/liveChatMessages/list>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

messages <- list_live_chat_messages(live_chat_id = "Cg0KC...")
} # }
```
