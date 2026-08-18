# Compare multiple channels

Compares statistics and performance metrics across multiple YouTube
channels.

## Usage

``` r
compare_channels(
  channel_ids,
  metrics = c("subscriber_count", "video_count", "view_count"),
  auth = "key",
  simplify = TRUE,
  ...
)
```

## Arguments

- channel_ids:

  Vector of channel IDs to compare

- metrics:

  Metrics to include in comparison

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- simplify:

  Whether to return a simplified comparison table

- ...:

  Additional arguments passed to API functions

## Value

List or data frame with channel comparison

## Examples

``` r
if (FALSE) { # \dontrun{
# Compare two channels
channels <- c("UCuAXFkgsw1L7xaCfnd5JJOw", "UCsXVk37bltHxD1rDPwtNM8Q")
comparison <- compare_channels(channels)

# Custom metrics comparison
comparison <- compare_channels(channels,
                              metrics = c("subscriber_count", "video_count", "view_count"))
} # }
```
