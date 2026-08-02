This is a patch release for 1.4.1, fixing seven defects in how requests are
built and how responses are assembled.

## Test environments
* macOS (Tahoe 26.3.1), R 4.5.2
* win-builder, R-devel and R-release
* macOS builder (mac.R-project.org)
* GitHub Actions: ubuntu (devel, release, oldrel-1), macOS, windows

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs.

## Summary of changes

* `list_videocats()` and `list_guidecats()` placed the translated filter in the
  query list as an unnamed element. Both httr and httr2 reject a query with an
  unnamed component, so neither function could issue a request at all. The
  filter is now merged by name.

  For `list_guidecats()` this repairs the client rather than restoring the
  feature: Google deprecated the `guideCategories` endpoint in September 2020
  and it no longer returns data.

* The same two functions indexed a named character vector with `$`, which is an
  error on an atomic vector rather than a lookup.

* `get_live_streams()` required `stream_id` or `channel_id` and then sent
  `channelId`. `liveBroadcasts.list` has no `channelId` parameter and accepts
  exactly one of `broadcastStatus`, `id` or `mine`, so a status-only query was
  impossible and the combinations it did send were invalid. It now takes
  exactly one filter and gains `mine`.

* `get_comments(simplify = TRUE)` assigned the first comment's id to every row,
  because a scalar was recycled across the data frame; the second and later ids
  were lost. It also sent `pageToken` and `maxResults` alongside a `comment_id`
  filter, which `comments.list` documents as unsupported with `id`.

* `get_comments()` documented and validated a `page_token` argument that never
  reached the query, so paging through replies always returned the first page.

* `list_regions()` and `list_abuse_report_reasons()` documented and validated an
  `hl` argument that never reached the query.

* `list_videocats()` returned `snippet.assignable` as the string `"TRUE"`, and
  the column's type depended on whether any rows were returned. It is logical
  in both cases now.

## Other changes

* Tests move to testthat edition 3, and the deprecated `context()` and
  `expect_that(x, is_a(...))` idioms are retired.
* `tests/testthat/token_file.rds.enc`, an obsolete encrypted OAuth artifact,
  is excluded from the tarball.
* The minimum testthat is raised to 3.1.7, which is where
  `local_mocked_bindings()` was introduced and which the tests require.

## Reverse dependencies
There are no reverse dependencies.
