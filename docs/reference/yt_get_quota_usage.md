# Get Current Quota Usage

Returns session-local estimated quota usage for the current quota day.
Actual project usage is available in the Google Cloud Console.

## Usage

``` r
yt_get_quota_usage()
```

## Value

A data frame with one row per quota bucket and columns for estimated
usage, configured limits, remaining quota, and reset time.

## Examples

``` r
if (FALSE) { # \dontrun{
quota_status <- yt_get_quota_usage()
quota_status[quota_status$bucket == "data", ]
} # }
```
