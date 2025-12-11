# Validate that parameter matches allowed values

Modern validation using checkmate for better performance and consistency

## Usage

``` r
validate_choice(value, name, allowed, any.missing = FALSE)
```

## Arguments

- value:

  The value to validate

- name:

  The parameter name for error messages

- allowed:

  Vector of allowed values

- any.missing:

  Allow missing/NA values

## Value

Invisible NULL if valid, stops execution if invalid
