# Validate YouTube-specific IDs and parameters

Specialized validation functions for YouTube API parameters Validate
max_results parameter

## Usage

``` r
validate_max_results(max_results, api_max = 50, name = "max_results")
```

## Arguments

- max_results:

  Value to validate

- api_max:

  Maximum allowed by the API endpoint (default: 50)

- name:

  Parameter name for error messages

## Value

Invisible NULL if valid, stops execution if invalid
