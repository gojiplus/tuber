# Get playlist information for multiple playlists in batches

Efficiently retrieves playlist information for multiple playlist IDs
using batch requests.

## Usage

``` r
get_playlists_batch(
  playlist_ids,
  part = "snippet,status,contentDetails",
  batch_size = 50,
  simplify = TRUE,
  auth = "token",
  show_progress = TRUE,
  ...
)
```

## Arguments

- playlist_ids:

  Character vector of playlist IDs

- part:

  Character vector of parts to retrieve

- batch_size:

  Number of playlists per API call (max 50)

- simplify:

  Whether to return a simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- show_progress:

  Whether to show progress for large batches

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame containing playlist information

## Examples

``` r
if (FALSE) { # \dontrun{
playlist_ids <- c("PLbpi6ZahtOH6Blw3RGYpWkSByi_T7Rygb", "PLbpi6ZahtOH7X7tNwcp9bJ2pdhKp0HcC6")
playlists <- get_playlists_batch(playlist_ids)
} # }
```
