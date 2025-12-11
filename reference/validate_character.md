# Validate required character parameters

Modern validation using checkmate for better performance and consistency

## Usage

``` r
validate_character(
  value,
  name,
  allow_empty = FALSE,
  any.missing = FALSE,
  min.chars = NULL
)
```

## Arguments

- value:

  The value to validate

- name:

  The parameter name for error messages

- allow_empty:

  Whether to allow empty strings

- any.missing:

  Allow missing/NA values

- min.chars:

  Minimum number of characters

## Value

Invisible NULL if valid, stops execution if invalid
