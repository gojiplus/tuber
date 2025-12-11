# Get details for multiple videos in batches

Efficiently retrieves video details for multiple video IDs using batch
requests. Much more quota-efficient than calling get_video_details() in
a loop.

## Usage

``` r
get_videos_batch(
  video_ids,
  part = "snippet,statistics",
  batch_size = 50,
  simplify = TRUE,
  auth = "token",
  show_progress = TRUE,
  ...
)
```

## Arguments

- video_ids:

  Character vector of video IDs

- part:

  Character vector of parts to retrieve (snippet, statistics, etc.)

- batch_size:

  Number of videos per API call (max 50)

- simplify:

  Whether to return a simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- show_progress:

  Whether to show progress for large batches

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame containing video details

## Examples

``` r
if (FALSE) { # \dontrun{
video_ids <- c("dQw4w9WgXcQ", "M7FIvfx5J10", "kJQP7kiw5Fk")
details <- get_videos_batch(video_ids, part = c("snippet", "statistics"))
} # }
```
