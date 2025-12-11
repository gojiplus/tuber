# Get Current Quota Usage

Returns the current estimated quota usage for the day

## Usage

``` r
yt_get_quota_usage()
```

## Value

List with quota_used, quota_limit, quota_remaining, and reset_time

## Examples

``` r
if (FALSE) { # \dontrun{
quota_status <- yt_get_quota_usage()
cat("Used:", quota_status$quota_used, "/", quota_status$quota_limit)
} # }
```
