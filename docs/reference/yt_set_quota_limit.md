# Set Quota Limit

Set the daily quota limit (default is 10,000 units)

## Usage

``` r
yt_set_quota_limit(limit, bucket = "data")
```

## Arguments

- limit:

  Integer. Daily quota limit for the selected bucket.

- bucket:

  Quota bucket: \`"data"\`, \`"search"\`, or \`"video_uploads"\`.

## Examples

``` r
if (FALSE) { # \dontrun{
# If you have a higher quota limit
yt_set_quota_limit(50000, bucket = "data")
} # }
```
