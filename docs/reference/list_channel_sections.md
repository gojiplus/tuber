# List Channel Sections

Returns channel sections matching exactly one supported YouTube filter.

## Usage

``` r
list_channel_sections(
  channel_id = NULL,
  section_ids = NULL,
  mine = FALSE,
  part = c("snippet", "contentDetails"),
  simplify = TRUE,
  auth = if (mine) "token" else "key",
  ...
)
```

## Arguments

- channel_id:

  Channel whose sections should be returned.

- section_ids:

  One or more channel-section IDs.

- mine:

  Set to \`TRUE\` to return sections for the authenticated user's
  channel.

- part:

  Character vector of resource parts to return.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw API
  response.

- auth:

  Authentication method, \`"token"\` or \`"key"\`. \`mine = TRUE\`
  requires \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a channel-section list
response.

## References

<https://developers.google.com/youtube/v3/docs/channelSections/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_channel_sections(channel_id = "UCRw8bIz2wMLmfgAgWm903cA")
list_channel_sections(mine = TRUE, auth = "token")
} # }
```
