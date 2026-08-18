# List Super Chat Events

Retrieves Super Chat events for a channel associated with the
authenticated user. This endpoint requires OAuth 2.0 authentication and
the channel must be approved for Super Chat.

## Usage

``` r
list_super_chat_events(
  part = "snippet",
  language = NULL,
  max_results = 50,
  page_token = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- part:

  Parts to retrieve. Valid values are "snippet". Default is "snippet".

- language:

  Optional language code for localized text.

- max_results:

  Maximum total number of events to return.

- page_token:

  Specific page token to retrieve. Optional.

- simplify:

  Whether to return a simplified data.frame. Default is TRUE.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

A data.frame or list of Super Chat events.

## References

<https://developers.google.com/youtube/v3/live/docs/superChatEvents/list>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

super_chats <- list_super_chat_events()
} # }
```
