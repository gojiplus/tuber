# Wrapper for tuber API calls with built-in retry logic

Wrapper for tuber API calls with built-in retry logic

## Usage

``` r
call_api_with_retry(api_function, ..., retry_config = list())
```

## Arguments

- api_function:

  The tuber API function to call

- ...:

  Arguments to pass to the API function

- retry_config:

  List of retry configuration options

## Value

Result of API function call
