# Safely Convert Text to UTF-8

Ensures text fields are properly encoded in UTF-8

## Usage

``` r
safe_utf8(text, fallback_encoding = "latin1")
```

## Arguments

- text:

  Character vector or list of text to convert

- fallback_encoding:

  Character. Encoding to assume if detection fails. Default: "latin1"

## Value

Character vector with UTF-8 encoding
