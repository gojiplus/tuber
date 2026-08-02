This is a patch release for version 1.4.1, fixing five request-assembly
defects. Two of them meant `list_videocats()` and `list_guidecats()` could not
issue a request at all.

## Test environments
* Mac OS (Tahoe 26.3.1), R 4.5.2 (2025-10-31)
* checked on win-builder (devel and release)
* GitHub Actions: ubuntu (devel, release, oldrel-1), macOS, windows

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs.

## Summary of changes

* `list_videocats()` and `list_guidecats()` built their query as
  `list(part = "snippet", hl = hl, filter)`. Because `filter` is a named
  character vector, this placed it as a single unnamed list element rather than
  splicing its entries in. Both httr and httr2 reject a query containing an
  unnamed component, so neither function could reach the API. The filter is now
  merged by name.

* The same two functions indexed that vector with `filter$regionCode`, which is
  an error on an atomic vector rather than a lookup. Both now index by name and
  return a `data.frame` in every case, including when no items are returned.

* `get_comments()` documented and validated a `page_token` argument that never
  reached the query, so paging through replies always returned the first page.

* `list_regions()` and `list_abuse_report_reasons()` documented and validated an
  `hl` argument that never reached the query, though both endpoints support it
  and the sibling `list_langs()` already sent it.

* `get_live_streams()` sent its `status` filter as `eventType`, which is a
  `search.list` parameter; `liveBroadcasts.list` filters on `broadcastStatus`.

## Reverse dependencies
There are no reverse dependencies.
