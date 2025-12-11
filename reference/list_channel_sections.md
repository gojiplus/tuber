# List Channel Sections

Returns list of channel sections that channel id belongs to.

## Usage

``` r
list_channel_sections(filter = NULL, part = "snippet", hl = NULL, ...)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `channel_id`: Channel ID `id`: Section ID

- part:

  specify which part do you want. It can only be one of the following:
  `contentDetails, id, localizations, snippet, targeting`. Default is
  `snippet`.

- hl:

  language that will be used for text values, optional, default is
  en-US. See also
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md)

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

captions for the video from one of the first track

## References

<https://developers.google.com/youtube/v3/docs/activities/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_channel_sections(c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA"))
} # }
```
