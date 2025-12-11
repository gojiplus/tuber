# Get live stream information

Retrieves information about live streams and premieres.

## Usage

``` r
get_live_streams(
  stream_id = NULL,
  channel_id = NULL,
  part = "snippet,status",
  status = NULL,
  simplify = TRUE,
  auth = "token",
  ...
)
```

## Arguments

- stream_id:

  Live stream ID (optional if using other filters)

- channel_id:

  Channel ID to get live streams for

- part:

  Parts to retrieve

- status:

  Filter by status: "active", "upcoming", "completed"

- simplify:

  Whether to return a simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame with live stream information

## Examples

``` r
if (FALSE) { # \dontrun{
# Get live streams for a channel
streams <- get_live_streams(channel_id = "UCuAXFkgsw1L7xaCfnd5JJOw")

# Get specific live stream details
stream <- get_live_streams(stream_id = "abc123", part = c("snippet", "status"))
} # }
```
