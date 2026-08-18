# Safely extract field from list/object

Extracts a field from an object, returning a default value if the field
is missing or NULL.

## Usage

``` r
safe_extract(obj, field, default = NA_character_)
```

## Arguments

- obj:

  Object to extract from

- field:

  Field name (character)

- default:

  Default value if field missing. Default: NA_character\_

## Value

The field value or default
