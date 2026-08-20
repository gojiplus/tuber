# List live broadcasts

Retrieves YouTube \`liveBroadcast\` resources owned by the authenticated
user.

## Usage

``` r
list_live_broadcasts(
  broadcast_ids = NULL,
  part = "snippet,status",
  status = NULL,
  mine = FALSE,
  broadcast_type = NULL,
  max_results = 50,
  page_token = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- broadcast_ids:

  Broadcast IDs. Supply exactly one of \`broadcast_ids\`, \`status\`, or
  \`mine = TRUE\`.

- part:

  Parts to retrieve

- status:

  Filter by status: \`"active"\`, \`"all"\`, \`"upcoming"\`, or
  \`"completed"\`.

- mine:

  Logical. List the authenticated user's own broadcasts.

- broadcast_type:

  Optional broadcast type: \`"all"\`, \`"event"\`, or \`"persistent"\`.

- max_results:

  Maximum number of broadcasts to return.

- page_token:

  Page token at which to start.

- simplify:

  Whether to return a simplified data frame

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame with live stream information

## Examples

``` r
if (FALSE) { # \dontrun{
broadcasts <- list_live_broadcasts(status = "active")

broadcast <- list_live_broadcasts(
  broadcast_ids = "abc123",
  part = c("snippet", "status")
)
} # }
```
