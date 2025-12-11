# Cached version of tuber_GET with automatic caching

Cached version of tuber_GET with automatic caching

## Usage

``` r
tuber_GET_cached(
  path,
  query,
  auth = "token",
  cache_ttl = NULL,
  force_refresh = FALSE,
  ...
)
```

## Arguments

- path:

  API endpoint path

- query:

  Query parameters

- auth:

  Authentication method

- cache_ttl:

  Override default TTL for this call

- force_refresh:

  Skip cache and force fresh API call

- ...:

  Additional arguments passed to tuber_GET

## Value

API response (from cache or fresh call)
