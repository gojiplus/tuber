# Get Comments

Get Comments

## Usage

``` r
get_comments(
  filter = NULL,
  part = "snippet",
  max_results = 100,
  text_format = "html",
  page_token = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `comment_id`: comment ID. `parent_id`: parent ID.

- part:

  Comment resource requested. Required. Comma separated list of one or
  more of the following: `id, snippet`. e.g., `"id, snippet"`, `"id"`,
  etc. Default: `snippet`.

- max_results:

  Maximum number of items that should be returned. Integer. Optional.
  Can be between 20 and 100. Default is 100.

- text_format:

  Data Type: Character. Default is `"html"`. Only takes `"html"` or
  `"plainText"`. Optional.

- page_token:

  Specific page in the result set that should be returned. Optional.

- simplify:

  Data Type: Boolean. Default is TRUE. If TRUE, the function returns a
  data frame. Else a list with all the information returned.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

Nested named list. The entry `items` is a list of comments along with
meta information. Within each of the `items` is an item `snippet` which
has an item `topLevelComment$snippet$textDisplay` that contains the
actual comment.

When filter is `comment_id`, and `simplify` is `TRUE`, and there is a
correct comment id, it returns a `data.frame` with the following cols:
`id, authorDisplayName, authorProfileImageUrl, authorChannelUrl, value, textDisplay, canRate, viewerRating, likeCount publishedAt, updatedAt`

## References

<https://developers.google.com/youtube/v3/docs/comments/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

get_comments(filter = c(comment_id = "z13dh13j5rr0wbmzq04cifrhtuypwl4hsdk"))
get_comments(filter = c(parent_id = "z13ds5yxjq3zzptyx04chlkbhx2yh3ezxtc0k"))
get_comments(filter =
c(comment_id = "z13dh13j5rr0wbmzq04cifrhtuypwl4hsdk,
             z13dh13j5rr0wbmzq04cifrhtuypwl4hsdk"))
} # }
```
