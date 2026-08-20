# List Supported Content Regions

List Supported Content Regions

## Usage

``` r
list_regions(language = NULL, auth = "key", ...)
```

## Arguments

- language:

  Optional language code for localized names.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame with \`region_code\`, \`name\`, and \`etag\` columns.

## References

<https://developers.google.com/youtube/v3/docs/i18nRegions/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_regions()
} # }
```
