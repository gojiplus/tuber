# List (Most Popular) Videos

List (Most Popular) Videos

## Usage

``` r
list_videos(
  part = "contentDetails",
  max_results = 50,
  page_token = NULL,
  hl = NULL,
  region_code = NULL,
  video_category_id = NULL,
  ...
)
```

## Arguments

- part:

  Required. Comma separated string including one or more of the
  following:
  `contentDetails, fileDetails, id, liveStreamingDetails, localizations, player, processingDetails, recordingDetails, snippet, statistics, status, suggestions, topicDetails`.
  Default: `contentDetails`.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Default is 50. Values over 50 will trigger multiple requests and may
  use additional API quota.

- page_token:

  specific page in the result set that should be returned, optional

- hl:

  Language used for text values. Optional. Default is `en-US`. For other
  allowed language codes, see
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md).

- region_code:

  Character. Required. Has to be a ISO 3166-1 alpha-2 code (see
  <https://www.iso.org/obp/ui/#search>).

- video_category_id:

  the video category for which the chart should be retrieved. See also
  [`list_videocats`](https://gojiplus.github.io/tuber/reference/list_videocats.md).

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

data.frame with 5 columns: `channelId, title, assignable, etag, id`

## References

<https://developers.google.com/youtube/v3/docs/search/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_videos()
} # }
```
