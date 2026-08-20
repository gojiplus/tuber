# GET

GET

## Usage

``` r
tuber_GET(
  path,
  query,
  auth = "token",
  use_cache = TRUE,
  cache_ttl = NULL,
  force_refresh = FALSE,
  ...
)
```

## Arguments

- path:

  path to specific API request URL

- query:

  query list

- auth:

  A character vector of the authentication method, either "token" (the
  default) or "key"

- use_cache:

  Logical. Whether eligible responses may be served from and stored in
  the tuber cache.

- cache_ttl:

  Optional cache lifetime in seconds.

- force_refresh:

  Logical. Ignore a cached response and refresh it.

- ...:

  Ignored; retained so callers that forwarded httr configuration keep
  working.

## Value

list
