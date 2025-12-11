# Get Channel Statistics

Get statistics and details for one or more YouTube channels efficiently
using batch processing.

## Usage

``` r
get_channel_stats(
  channel_ids = NULL,
  mine = NULL,
  part = c("statistics", "snippet"),
  simplify = FALSE,
  batch_size = 50,
  show_progress = NULL,
  auth = "token",
  console_output = TRUE,
  ...
)

list_my_channel(...)
```

## Arguments

- channel_ids:

  Character vector of channel IDs to retrieve. Use `list_my_channel()`
  to get your own channel ID.

- mine:

  Logical. Set to TRUE to get authenticated user's channel. Overrides
  `channel_ids`. Default: NULL.

- part:

  Character vector of parts to retrieve. Default: c("statistics",
  "snippet").

- simplify:

  Logical. If TRUE, returns a data frame. If FALSE, returns raw list.
  Default: FALSE.

- batch_size:

  Number of channels per API call (max 50). Default: 50.

- show_progress:

  Whether to show progress for large batches. Default: TRUE for \>10
  channels.

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key). Default:
  "token".

- console_output:

  Logical. Show console output for single channel. Default: TRUE.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

When `simplify = FALSE` (default): List with channel details. When
`simplify = TRUE`: Data frame with channel details.

For single channels, returns the channel object directly (not in a
list). For multiple channels, returns a list with items array.

## Details

Valid parts include:
`auditDetails, brandingSettings, contentDetails, contentOwnerDetails, id, localizations, snippet, statistics, status, topicDetails`.

The function automatically batches requests to minimize API quota
usage: - 1 channel = 1 API call - 100 channels = 2 API calls (batched in
groups of 50)

When retrieving a single channel, the function displays key statistics
in the console by default (can be disabled with
`console_output = FALSE`).

## References

<https://developers.google.com/youtube/v3/docs/channels/list>

## Examples

``` r
if (FALSE) { # \dontrun{
# Get stats for a single channel - displays console output
stats <- get_channel_stats("UCT5Cx1l4IS3wHkJXNyuj4TA")

# Get stats for multiple channels - automatically batched
channel_ids <- c("UCT5Cx1l4IS3wHkJXNyuj4TA", "UCfK2eFCRQ64Gqfrpbrcj31w")
stats <- get_channel_stats(channel_ids)

# Get as data frame
df <- get_channel_stats(channel_ids, simplify = TRUE)

# Get your own channel stats
my_stats <- get_channel_stats(mine = TRUE)

# Get additional parts
detailed <- get_channel_stats(channel_ids, 
                             part = c("statistics", "snippet", "brandingSettings"))
} # }
```
