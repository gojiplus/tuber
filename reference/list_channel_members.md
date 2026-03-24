# List Channel Members

Retrieves a list of members for a channel associated with the
authenticated user. This endpoint requires OAuth 2.0 authentication and
the channel must have memberships enabled.

## Usage

``` r
list_channel_members(
  part = "snippet",
  max_results = 50,
  page_token = NULL,
  mode = "all_current",
  has_access_to_level = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- part:

  Parts to retrieve. Valid values are "snippet". Default is "snippet".

- max_results:

  Maximum number of items to return. Default is 50. Max is 1000.

- page_token:

  Specific page token to retrieve. Optional.

- mode:

  Filter for members. Valid values: "all_current", "newest". Default is
  "all_current".

- has_access_to_level:

  Filter by a specific membership level ID. Optional.

- simplify:

  Whether to return a simplified data.frame. Default is TRUE.

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

A data.frame or list of channel members.

## References

<https://developers.google.com/youtube/v3/docs/members/list>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

members <- list_channel_members()
} # }
```
