# Handle HTTP response for quota and rate limiting errors

Centralized error handling for all tuber HTTP functions. Checks for
quota exceeded (403) and rate limiting (429) errors.

## Usage

``` r
handle_http_response(req)
```

## Arguments

- req:

  The HTTP response object

## Value

NULL invisibly if no errors, otherwise stops with informative message
