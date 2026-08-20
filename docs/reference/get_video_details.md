# Get Video Details

Get details for one or more YouTube videos efficiently using batch
processing.

## Usage

``` r
get_video_details(
  video_ids,
  part = "snippet",
  simplify = TRUE,
  batch_size = 50,
  show_progress = NULL,
  auth = "key",
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
  Default: TRUE.

- batch_size:

  Number of videos per API call (max 50). Default: 50.

- show_progress:

  Whether to show progress for large batches. Default: TRUE for \>10
  videos.

- auth:

  Authentication method, \`"key"\` (the default) or \`"token"\`.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

When `simplify = TRUE` (default): a data frame whose columns mirror the
requested API parts. Since \`part\` is user-selectable, these columns
retain YouTube's field names rather than the fixed snake-case schemas
used by \`list\_\*()\` functions. Owner-only parts cannot be simplified.
When `simplify = FALSE`: List with items containing video details.

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

# Preserve the nested API resource when that is easier to inspect:
details <- get_video_details("yJXTXN4xrI8", simplify = FALSE)
title <- details$items[[1]]$snippet$title
} # }
```
