# List Content Regions That YouTube Currently Supports

List Content Regions That YouTube Currently Supports

## Usage

``` r
list_regions(hl = NULL, ...)
```

## Arguments

- hl:

  Language used for text values. Optional. Default is `en-US`. For other
  allowed language codes, see
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md).

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

data.frame with 3 columns: `gl` (two letter abbreviation), `name` (of
the region), `etag`

## References

<https://developers.google.com/youtube/v3/docs/i18nRegions/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_regions()
} # }
```
