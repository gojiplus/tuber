# Parse a JSON response body, tolerating an empty one

A 204 carries no body, and resp_body_json() errors rather than returning
nothing.

## Usage

``` r
tuber_json(resp)
```

## Arguments

- resp:

  An httr2 response

## Value

A list, or NULL when the response has no body
