# Get Comments Threads

Get Comments Threads

## Usage

``` r
get_comment_threads(
  filter = NULL,
  part = "snippet",
  text_format = "html",
  simplify = TRUE,
  max_results = 100,
  page_token = NULL,
  ...
)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `video_id`: video ID. `channel_id`: channel ID.
  `thread_id`: comma-separated list of comment thread IDs
  `threads_related_to_channel`: channel ID.

- part:

  Comment resource requested. Required. Comma separated list of one or
  more of the following: `id, replies, snippet`. e.g., `"id,snippet"`,
  `"replies"`, etc. Default: `snippet`.

- text_format:

  Data Type: Character. Default is `"html"`. Only takes `"html"` or
  `"plainText"`. Optional.

- simplify:

  Data Type: Boolean. Default is `TRUE`. If `TRUE`, the function returns
  a data frame. Else a list with all the information returned.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Can be 1-2000. Default is 100. If the value is greater than 100,
  multiple API calls are made to fetch all results. Each API call is
  limited to 100 items per the YouTube API.

- page_token:

  Specific page in the result set that should be returned. Optional.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

Nested named list. The entry `items` is a list of comments along with
meta information. Within each of the `items` is an item `snippet` which
has an item `topLevelComment$snippet$textDisplay` that contains the
actual comment.

If simplify is `TRUE`, a `data.frame` with the following columns:
`authorDisplayName, authorProfileImageUrl, authorChannelUrl, authorChannelId.value, videoId, textDisplay, canRate, viewerRating, likeCount, publishedAt, updatedAt`

## References

<https://developers.google.com/youtube/v3/docs/commentThreads/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_comment_threads(filter = c(video_id = "N708P-A45D0"))
get_comment_threads(filter = c(video_id = "N708P-A45D0"), max_results = 101)
} # }
```
