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
  filter_by_member_channel_ids = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- part:

  Parts to retrieve. Valid values are "snippet". Default is "snippet".

- max_results:

  Maximum total number of members to return.

- page_token:

  Specific page token to retrieve. Optional.

- mode:

  Member stream, \`"all_current"\` or \`"updates"\`.

- has_access_to_level:

  Filter by a specific membership level ID. Optional.

- filter_by_member_channel_ids:

  Optional member channel IDs whose membership status should be checked.
  YouTube accepts at most 100 per call.

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
yt_oauth("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET", scope = "channel_memberships")
members <- list_channel_members()
} # }
```
