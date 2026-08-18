# Returns List of Requested Channel Videos

Retrieves items from a channel's uploads playlist.

## Usage

``` r
list_channel_videos(
  channel_id,
  max_results = 50,
  page_token = NULL,
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- channel_id:

  String. ID of the channel. Required.

- max_results:

  Maximum total number of videos returned.

- page_token:

  Specific page in the result set that should be returned. Optional.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw
  playlist-items response.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

A data frame when \`simplify = TRUE\`; otherwise a playlist-items
response.

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
