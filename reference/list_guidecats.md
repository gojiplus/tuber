# Get list of categories that can be associated with YouTube channels

Get list of categories that can be associated with YouTube channels

## Usage

``` r
list_guidecats(filter = NULL, hl = NULL, ...)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `region_code`: Character. Required. Has to be a
  ISO 3166-1 alpha-2 code (see <https://www.iso.org/obp/ui/#search>)
  `category_id`: YouTube channel category ID

- hl:

  Language used for text values. Optional. Default is `en-US`. For other
  allowed language codes, see
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md).

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

data.frame with 5 columns: `region_code, channelId, title, etag, id`

## References

<https://developers.google.com/youtube/v3/docs/guideCategories/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_guidecats(c(region_code = "JP"))
} # }
```
