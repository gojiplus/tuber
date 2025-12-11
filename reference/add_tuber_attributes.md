# Add standardized metadata attributes to API response

Adds consistent metadata attributes to function return values for better
debugging and quota management.

## Usage

``` r
add_tuber_attributes(
  result,
  api_calls_made = 1,
  quota_used = NULL,
  function_name = NULL,
  parameters = list(),
  timestamp = Sys.time(),
  ...
)
```

## Arguments

- result:

  The result object to add attributes to

- api_calls_made:

  Number of API calls made to generate this result

- quota_used:

  Estimated quota units consumed

- function_name:

  Name of the calling function

- parameters:

  List of key parameters used in the function call

- timestamp:

  When the API call was made

- ...:

  Additional custom attributes

## Value

The result object with standardized attributes added
