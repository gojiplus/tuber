# Get live stream information

Retrieves information about live streams and premieres.

## Usage

``` r
get_live_streams(
  stream_id = NULL,
  channel_id = NULL,
  part = "snippet,status",
  status = NULL,
  mine = FALSE,
  simplify = TRUE,
  auth = "token",
  ...
)
```

## Arguments

- stream_id:

  Live stream ID (optional if using other filters)

- channel_id:

  Deprecated. liveBroadcasts.list has no channelId parameter; supplying
  it is an error. Use `status` or `mine`.

- part:

  Parts to retrieve

- status:

  Filter by status: "active", "upcoming", "completed"

- mine:

  Logical. List the authenticated user's own broadcasts.

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
streams <- get_live_streams(status = "active")

# Get specific live stream details
stream <- get_live_streams(stream_id = "abc123", part = c("snippet", "status"))
} # }
```
