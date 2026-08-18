# List Supported Languages

List Supported Languages

## Usage

``` r
list_languages(language = NULL, auth = "key", ...)
```

## Arguments

- language:

  Optional language code for localized names.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame with \`language_code\`, \`name\`, and \`etag\` columns.

## References

<https://developers.google.com/youtube/v3/docs/i18nLanguages/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_languages()
} # }
```
