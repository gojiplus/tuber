# Validate numeric parameters with range checking

Modern validation using checkmate for better performance and consistency

## Usage

``` r
validate_numeric(
  value,
  name,
  min = -Inf,
  max = Inf,
  integer_only = FALSE,
  any.missing = FALSE
)
```

## Arguments

- value:

  The value to validate

- name:

  The parameter name for error messages

- min:

  Minimum allowed value

- max:

  Maximum allowed value

- integer_only:

  Whether value must be an integer

- any.missing:

  Allow missing/NA values

## Value

Invisible NULL if valid, stops execution if invalid
