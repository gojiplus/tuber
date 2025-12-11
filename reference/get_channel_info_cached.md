# Get channel information with caching (for static parts)

Get channel information with caching (for static parts)

## Usage

``` r
get_channel_info_cached(
  channel_id,
  part = "snippet,brandingSettings",
  auth = "key",
  cache_ttl = 3600,
  ...
)
```

## Arguments

- channel_id:

  Channel ID

- part:

  Parts to retrieve (only static parts will be cached)

- auth:

  Authentication method

- cache_ttl:

  Cache time-to-live (default: 1 hour for channel info)

- ...:

  Additional arguments

## Value

Channel information
