# Returns List of Requested Channel Resources

Returns List of Requested Channel Resources

## Usage

``` r
list_channel_resources(
  filter = NULL,
  part = "contentDetails",
  max_results = 50,
  page_token = NULL,
  hl = "en-US",
  ...
)
```

## Arguments

- filter:

  string; Required. named vector with a single valid name potential
  names of the entry in the vector: `category_id`: YouTube guide
  category that returns channels associated with that category
  `username`: YouTube username that returns the channel associated with
  that username. Multiple usernames can be provided. `channel_id`: a
  comma-separated list of the YouTube channel ID(s) for the resource(s)
  that are being retrieved

- part:

  a comma-separated list of channel resource properties that response
  will include a string. Required. One of the following:
  `auditDetails, brandingSettings, contentDetails, contentOwnerDetails, id, invideoPromotion, localizations, snippet, statistics, status, topicDetails`.
  Default is `contentDetails`.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Default is 50. Values over 50 will trigger additional requests and may
  increase API quota usage.

- page_token:

  specific page in the result set that should be returned, optional

- hl:

  Language used for text values. Optional. The default is `en-US`. For
  other allowed language codes, see
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md).

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

list. If `username` is used in `filter`, a data frame with columns
`username` and `channel_id` is returned.

## References

<https://developers.google.com/youtube/v3/docs/channels/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_channel_resources(filter = c(channel_id = "UCT5Cx1l4IS3wHkJXNyuj4TA"))
list_channel_resources(filter = c(username = "latenight"), part = "id")
list_channel_resources(filter = c(username = c("latenight", "PBS")),
                       part = "id")
} # }
```
