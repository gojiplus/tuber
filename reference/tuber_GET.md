# GET

GET

## Usage

``` r
tuber_GET(path, query, auth = "token", use_etag = TRUE, ...)
```

## Arguments

- path:

  path to specific API request URL

- query:

  query list

- auth:

  A character vector of the authentication method, either "token" (the
  default) or "key"

- use_etag:

  Logical. Whether to use ETag for caching. Default is TRUE.

- ...:

  Additional arguments passed to
  [`GET`](https://httr.r-lib.org/reference/GET.html).

## Value

list
