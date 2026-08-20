# Write request with a JSON body

Write request with a JSON body

## Usage

``` r
tuber_write(path, method, query, body = NULL, quota_method)
```

## Arguments

- path:

  path to specific API request URL

- method:

  HTTP method, one of "POST", "PUT" or "DELETE"

- query:

  query list

- body:

  list serialized as the JSON request body

- quota_method:

  quota category recorded for this call

## Value

An httr2 response
