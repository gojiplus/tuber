# List Subscriptions

Retrieves subscription resources using exactly one YouTube filter.

## Usage

``` r
list_subscriptions(
  channel_id = NULL,
  subscription_ids = NULL,
  mine = FALSE,
  my_recent_subscribers = FALSE,
  my_subscribers = FALSE,
  for_channel_ids = NULL,
  part = c("snippet", "contentDetails"),
  order = "relevance",
  max_results = 50,
  page_token = NULL,
  simplify = TRUE,
  auth = if (mine || my_recent_subscribers || my_subscribers) {
     "token"
 } else {
  
      "key"
 },
  ...
)
```

## Arguments

- channel_id:

  Optional channel whose public subscriptions to retrieve.

- subscription_ids:

  Optional character vector of subscription IDs.

- mine:

  If \`TRUE\`, retrieve channels the authenticated user subscribes to.

- my_recent_subscribers:

  If \`TRUE\`, retrieve the authenticated channel's recent subscribers.

- my_subscribers:

  If \`TRUE\`, retrieve the authenticated channel's subscribers.

- for_channel_ids:

  Optional channel IDs used to narrow matching subscriptions.

- part:

  Character vector of subscription resource parts.

- order:

  Sort order: \`"alphabetical"\`, \`"relevance"\`, or \`"unread"\`.

- max_results:

  Maximum total number of subscriptions to return.

- page_token:

  Optional page token at which to start.

- simplify:

  If \`TRUE\`, return a data frame; otherwise return the raw API
  response with all collected items.

- auth:

  Authentication method, \`"key"\` or \`"token"\`. Authenticated-user
  filters require OAuth.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame when \`simplify = TRUE\`; otherwise a subscriptions-list
response.

## References

<https://developers.google.com/youtube/v3/docs/subscriptions/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_subscriptions(channel_id = "UChTJTbr5kf3hYazJZO-euHg")
list_subscriptions(mine = TRUE)
} # }
```
