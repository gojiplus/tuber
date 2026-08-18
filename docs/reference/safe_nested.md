# Safely extract nested field

Extracts a value from nested list structures, returning a default value
if any level of the path is missing.

## Usage

``` r
safe_nested(obj, ..., default = NA_character_)
```

## Arguments

- obj:

  Object to extract from

- ...:

  Field names in order (e.g., "author", "id", "value")

- default:

  Default value if any field missing. Default: NA_character\_

## Value

The nested field value or default
