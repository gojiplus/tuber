# Build httr2 request for YouTube API

Internal helper to construct httr2 requests with consistent
authentication and headers. Consolidates duplicated code across HTTP
functions.

## Usage

``` r
build_httr2_request(path, query)
```

## Arguments

- path:

  API endpoint path (e.g., "videos", "channels")

- query:

  Named list of query parameters

## Value

An httr2 request object ready for method-specific modifications
