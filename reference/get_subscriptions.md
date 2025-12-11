# Get Subscriptions

Get Subscriptions

## Usage

``` r
get_subscriptions(
  filter = NULL,
  part = "contentDetails",
  max_results = 50,
  for_channel_id = NULL,
  order = NULL,
  page_token = NULL,
  ...
)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `channel_id`: ID of the channel. Required. No
  default. `subscription_id`: YouTube subscription ID

- part:

  Part of the resource requested. Required. Character. A comma separated
  list of one or more of the following:
  `contentDetails, id, snippet, subscriberSnippet`. e.g. "id, snippet",
  "id", etc. Default: `contentDetails`.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Default is 50. Values over 50 will trigger additional requests and may
  increase API quota usage.

- for_channel_id:

  Optional. String. A comma-separated list of channel IDs. Limits
  response to subscriptions matching those channels.

- order:

  method that will be used to sort resources in the API response. Takes
  one of the following: alphabetical, relevance, unread

- page_token:

  Specific page in the result set that should be returned. Optional.
  String.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

named list of subscriptions

## References

<https://developers.google.com/youtube/v3/docs/subscriptions/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_subscriptions(filter = c(channel_id = "UChTJTbr5kf3hYazJZO-euHg"))
} # }
```
