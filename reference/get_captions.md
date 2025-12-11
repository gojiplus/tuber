# Get Particular Caption Track

For getting captions from the v3 API, you must specify the id resource.
Check
[`list_caption_tracks`](https://gojiplus.github.io/tuber/reference/list_caption_tracks.md)
for more information. IMPORTANT: This function requires OAuth
authentication and you must own the video or have appropriate
permissions to access its captions.

## Usage

``` r
get_captions(id = NULL, lang = "en", format = "sbv", as_raw = TRUE, ...)
```

## Arguments

- id:

  String. Required. id of the caption track that is being retrieved

- lang:

  Optional. Default is `en`.

- format:

  Optional. Default is `sbv`.

- as_raw:

  If `FALSE` the captions be converted to a character string versus a
  raw vector

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

String.

## References

<https://developers.google.com/youtube/v3/docs/captions/download>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first
# You must own the video to download captions

get_captions(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
} # }
```
