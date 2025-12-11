# Enhanced versions of static data functions with caching

These functions automatically cache responses to reduce API quota usage
for data that changes infrequently. List video categories with caching

## Usage

``` r
list_videocats_cached(region_code = "US", auth = "key", cache_ttl = 86400, ...)
```

## Arguments

- region_code:

  Region code for categories

- auth:

  Authentication method

- cache_ttl:

  Cache time-to-live (default: 24 hours for categories)

- ...:

  Additional arguments

## Value

Video categories data
