# Configure caching settings

Configure caching settings

## Usage

``` r
tuber_cache_config(
  enabled = TRUE,
  default_ttl = 3600,
  max_size = 1000,
  cache_dir = NULL
)
```

## Arguments

- enabled:

  Whether to enable caching globally

- default_ttl:

  Default time-to-live in seconds

- max_size:

  Maximum number of cached items

- cache_dir:

  Directory for persistent cache (NULL for memory only)
