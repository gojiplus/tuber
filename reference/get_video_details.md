# Get Video Details

Get details for one or more YouTube videos efficiently using batch
processing.

## Usage

``` r
get_video_details(
  video_ids,
  part = "snippet",
  simplify = FALSE,
  batch_size = 50,
  show_progress = NULL,
  auth = "token",
  ...
)
```

## Arguments

- video_ids:

  Character vector of video IDs to retrieve

- part:

  Character vector of parts to retrieve. See `Details` for options.

- simplify:

  Logical. If TRUE, returns a data frame. If FALSE, returns raw list.
  Default: FALSE.

- batch_size:

  Number of videos per API call (max 50). Default: 50.

- show_progress:

  Whether to show progress for large batches. Default: TRUE for \>10
  videos.

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key). Default:
  "token".

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

When `simplify = FALSE` (default): List with items containing video
details. When `simplify = TRUE`: Data frame with video details (not
available for owner-only parts).

The result includes metadata as attributes: - `api_calls_made`: Number
of API calls made - `quota_used`: Estimated quota units consumed -
`videos_requested`: Number of videos requested - `results_found`: Number
of videos found

## Details

Valid values for `part`:
`contentDetails, fileDetails, id, liveStreamingDetails, localizations, paidProductPlacementDetails, player, processingDetails, recordingDetails, snippet, statistics, status, suggestions, topicDetails`.

Certain parts like `fileDetails, suggestions, processingDetails` are
only available to video owners and require OAuth authentication.

The function automatically batches requests to minimize API quota
usage: - 1 video = 1 API call - 100 videos = 2 API calls (batched in
groups of 50)

## References

<https://developers.google.com/youtube/v3/docs/videos/list>

## Examples

``` r
if (FALSE) { # \dontrun{
# Single video
details <- get_video_details("yJXTXN4xrI8")

# Multiple videos - automatically batched
video_ids <- c("yJXTXN4xrI8", "LDZX4ooRsWs", "kJQP7kiw5Fk")
details <- get_video_details(video_ids)

# Get as data frame
df <- get_video_details(video_ids, simplify = TRUE)

# Get specific parts
stats <- get_video_details(video_ids, part = c("statistics", "contentDetails"))

# Extract specific fields:
details <- get_video_details("yJXTXN4xrI8")
title <- details$items[[1]]$snippet$title
view_count <- details$items[[1]]$statistics$viewCount
} # }
```
