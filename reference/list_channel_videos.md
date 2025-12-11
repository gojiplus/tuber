# Returns List of Requested Channel Videos

Iterate through the `max_results` number of playlists in channel and get
the videos for each of the playlists.

## Usage

``` r
list_channel_videos(
  channel_id = NULL,
  max_results = 50,
  page_token = NULL,
  hl = "en-US",
  ...
)
```

## Arguments

- channel_id:

  String. ID of the channel. Required.

- max_results:

  Maximum number of videos returned. Integer. Default is 50. If the
  number is over 50, all the videos will be returned.

- page_token:

  Specific page in the result set that should be returned. Optional.

- hl:

  Language used for text values. Optional. Default is `en-US`. For other
  allowed language codes, see
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md)

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

list of `data.frame` with each list corresponding to a different
playlist

## References

<https://developers.google.com/youtube/v3/docs/channels/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_channel_videos(channel_id = "UCXOKEdfOFxsHO_-Su3K8SHg")
list_channel_videos(channel_id = "UCXOKEdfOFxsHO_-Su3K8SHg", max_results = 10)
} # }
```
