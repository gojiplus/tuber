# Comprehensive channel analysis

Performs a complete analysis of a YouTube channel including basic info,
statistics, recent videos, and performance metrics.

## Usage

``` r
analyze_channel(
  channel_id,
  max_videos = 50,
  auth = "key",
  include_comments = FALSE,
  ...
)
```

## Arguments

- channel_id:

  Channel ID to analyze

- max_videos:

  Maximum number of recent videos to analyze (default: 50)

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- include_comments:

  Whether to fetch comment statistics (requires more quota)

- ...:

  Additional arguments passed to API functions

## Value

List containing comprehensive channel analysis

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic channel analysis
analysis <- analyze_channel("UCuAXFkgsw1L7xaCfnd5JJOw")

# Detailed analysis with comments
detailed <- analyze_channel("UCuAXFkgsw1L7xaCfnd5JJOw",
                           max_videos = 100,
                           include_comments = TRUE)
} # }
```
