# Get Details of a Video or Videos

Get details such as when the video was published, the title,
description, thumbnails, category etc.

## Usage

``` r
get_video_details(
  video_id = NULL,
  part = "snippet",
  as.data.frame = FALSE,
  batch_size = 50,
  use_etag = TRUE,
  ...
)
```

## Arguments

- video_id:

  Comma separated list of IDs of the videos for which details are
  requested. Required.

- part:

  Comma-separated vector of video resource properties requested. Options
  include:
  `contentDetails, fileDetails, id, liveStreamingDetails, localizations, player, processingDetails, recordingDetails, snippet, statistics, status, suggestions, topicDetails`.
  Note: As of October 30, 2024, the `status` part includes
  `containsSyntheticMedia` property for identifying AI-generated
  content.

- as.data.frame:

  Logical, returns the requested information as data.frame. Does not
  work for: `fileDetails, suggestions, processingDetails`

- batch_size:

  Integer. When multiple video IDs are provided, controls batch size for
  efficient processing. Default is 50.

- use_etag:

  Logical. Whether to use ETag for caching. Default is TRUE.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

list. If part is snippet, the list will have the following elements:
`id` (video id that was passed),
`publishedAt, channelId, title, description, thumbnails, channelTitle, categoryId, liveBroadcastContent, localized, defaultAudioLanguage`

## References

<https://developers.google.com/youtube/v3/docs/videos/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_video_details(video_id = "yJXTXN4xrI8")
get_video_details(video_id = "yJXTXN4xrI8", part = "contentDetails")
# retrieve multiple parameters
get_video_details(video_id = "yJXTXN4xrI8", part = c("contentDetails", "status"))
# get details for multiple videos as data frame
get_video_details(video_id = c("LDZX4ooRsWs", "yJXTXN4xrI8"), as.data.frame = TRUE)

# Extract specific fields (common use case):
details <- get_video_details(video_id = "yJXTXN4xrI8")
# Get video title:
video_title <- details$items[[1]]$snippet$title
# Get video description:
video_desc <- details$items[[1]]$snippet$description

# Shiny usage - extract video title safely:
# output$videotitle <- renderText({
#   details <- get_video_details(input$commentkey)
#   if (length(details$items) > 0) {
#     details$items[[1]]$snippet$title
#   } else {
#     "Video not found"
#   }
# })
# Get channel ID:
channel_id <- details$items[[1]]$snippet$channelId

# For Shiny applications - extract title:
# output$videotitle <- renderText({
#   details <- get_video_details(input$video_id)
#   if (length(details$items) > 0) {
#     details$items[[1]]$snippet$title
#   } else {
#     "Video not found"
#   }
# })

# Check for AI-generated content (requires status part):
# status_details <- get_video_details(video_id = "yJXTXN4xrI8", part = "status")
# is_synthetic <- status_details$items[[1]]$status$containsSyntheticMedia
} # }
```
