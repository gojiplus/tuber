# Get Channel Details

Retrieves channels by ID, legacy username, guide category, or the
authenticated user's channel. Supply exactly one filter.

## Usage

``` r
get_channel_details(
  channel_ids = NULL,
  usernames = NULL,
  category_id = NULL,
  mine = FALSE,
  part = c("snippet", "statistics"),
  max_results = 50,
  language = NULL,
  simplify = TRUE,
  batch_size = 50,
  auth = if (mine) "token" else "key",
  ...
)

get_my_channel(
  part = c("snippet", "statistics"),
  language = NULL,
  simplify = TRUE,
  ...
)
```

## Arguments

- channel_ids:

  Optional character vector of channel IDs.

- usernames:

  Optional character vector of legacy YouTube usernames.

- category_id:

  Optional guide-category ID.

- mine:

  If \`TRUE\`, retrieve the authenticated user's channel.

- part:

  Character vector of channel resource parts.

- max_results:

  Maximum number of category-filtered channels to return.

- language:

  Optional language code for localized text.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return a channels list
  response with all collected items.

- batch_size:

  Number of channel IDs per request, at most 50.

- auth:

  Authentication method, \`"key"\` or \`"token"\`. \`mine = TRUE\`
  requires OAuth.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a channels-list
response.

## References

<https://developers.google.com/youtube/v3/docs/channels/list>

## Examples

``` r
if (FALSE) { # \dontrun{
get_channel_details(channel_ids = "UCT5Cx1l4IS3wHkJXNyuj4TA")
get_channel_details(usernames = c("GoogleDevelopers", "PBS"))
get_my_channel()
} # }
```
