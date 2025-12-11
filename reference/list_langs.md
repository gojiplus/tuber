# List Languages That YouTube Currently Supports

List Languages That YouTube Currently Supports

## Usage

``` r
list_langs(hl = NULL, ...)
```

## Arguments

- hl:

  Language used for text values. Optional. Default is `en-US`. For other
  allowed language codes, see `list_langs`.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

data.frame with 3 columns: `hl` (two letter abbreviation), `name` (of
the language), `etag`

## References

<https://developers.google.com/youtube/v3/docs/i18nLanguages/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_langs()
} # }
```
