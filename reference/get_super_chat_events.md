# Get Super Chat Events

Retrieves Super Chat events for a channel associated with the
authenticated user. This endpoint requires OAuth 2.0 authentication and
the channel must be approved for Super Chat.

## Usage

``` r
get_super_chat_events(
  part = "snippet",
  hl = NULL,
  max_results = 50,
  page_token = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- part:

  Parts to retrieve. Valid values are "snippet". Default is "snippet".

- hl:

  Language used for text values. Optional.

- max_results:

  Maximum number of items to return. Default is 50. Max is 50.

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

super_chats <- get_super_chat_events()
} # }
```
