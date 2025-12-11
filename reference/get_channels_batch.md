# Get statistics for multiple channels in batches

Efficiently retrieves channel statistics for multiple channel IDs using
batch requests.

## Usage

``` r
get_channels_batch(
  channel_ids,
  part = "statistics,snippet",
  batch_size = 50,
  simplify = TRUE,
  auth = "token",
  show_progress = TRUE,
  ...
)
```

## Arguments

- channel_ids:

  Character vector of channel IDs

- part:

  Character vector of parts to retrieve

- batch_size:

  Number of channels per API call (max 50)

- simplify:

  Whether to return a simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- show_progress:

  Whether to show progress for large batches

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame containing channel statistics

## Examples

``` r
if (FALSE) { # \dontrun{
channel_ids <- c("UCuAXFkgsw1L7xaCfnd5JJOw", "UCsXVk37bltHxD1rDPwtNM8Q")
stats <- get_channels_batch(channel_ids, part = c("statistics", "snippet"))
} # }
```
