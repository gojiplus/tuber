# List Channel Activity

Returns a list of channel events that match the request criteria.

## Usage

``` r
list_channel_activities(
  filter = NULL,
  part = "snippet",
  max_results = 50,
  page_token = NULL,
  published_after = NULL,
  published_before = NULL,
  region_code = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `channel_id`: ID of the channel. Required. No
  default.

- part:

  specify which part do you want. It can only be one of the three:
  `contentDetails, id, snippet`. Default is `snippet`.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Default is 50. Values over 50 will trigger additional requests and may
  increase API quota usage.

- page_token:

  specific page in the result set that should be returned, optional

- published_after:

  Character. Optional. RFC 339 Format. For instance,
  "1970-01-01T00:00:00Z"

- published_before:

  Character. Optional. RFC 339 Format. For instance,
  "1970-01-01T00:00:00Z"

- region_code:

  ISO 3166-1 alpha-2 country code, optional, see also
  [`list_regions`](https://gojiplus.github.io/tuber/reference/list_regions.md)

- simplify:

  Data Type: Boolean. Default is `TRUE`. If `TRUE` and if part requested
  is `contentDetails`, the function returns a `data.frame`. Else a list
  with all the information returned.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

named list If `simplify` is `TRUE`, a data.frame is returned with 18
columns:
`publishedAt, channelId, title, description, thumbnails.default.url, thumbnails.default.width, thumbnails.default.height, thumbnails.medium.url, thumbnails.medium.width, thumbnails.medium.height, thumbnails.high.url, thumbnails.high.width, thumbnails.high.height, thumbnails.standard.url, thumbnails.standard.width, thumbnails.standard.height, channelTitle, type`

## References

<https://developers.google.com/youtube/v3/docs/activities/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_channel_activities(filter = c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA"))
list_channel_activities(filter = c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA", regionCode="US"))
list_channel_activities(filter = c(channel_id = "UCMtFAi84ehTSYSE9XoHefig"),
                        published_before = "2016-02-10T00:00:00Z",
                        published_after = "2016-01-01T00:00:00Z")
} # }
```
