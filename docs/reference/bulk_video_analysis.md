# Bulk video performance analysis

Analyzes performance metrics for multiple videos in bulk.

## Usage

``` r
bulk_video_analysis(
  video_ids,
  include_comments = FALSE,
  benchmark_percentiles = c(0.25, 0.5, 0.75, 0.9),
  auth = "key",
  ...
)
```

## Arguments

- video_ids:

  Vector of video IDs to analyze

- include_comments:

  Whether to include comment analysis

- benchmark_percentiles:

  Percentiles to use for performance benchmarking

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- ...:

  Additional arguments passed to API functions

## Value

List containing bulk video analysis

## Examples

``` r
if (FALSE) { # \dontrun{
# Analyze multiple videos
video_ids <- c("dQw4w9WgXcQ", "M7FIvfx5J10", "kJQP7kiw5Fk")
analysis <- bulk_video_analysis(video_ids)

# Include comment analysis
detailed <- bulk_video_analysis(video_ids, include_comments = TRUE)
} # }
```
