# CLAUDE.md

This repository contains the `tuber` R package, a client for the YouTube Data
API and selected YouTube Live Streaming API endpoints.

## Required local checks

Run every command before declaring a change ready:

```r
devtools::document()
lintr::lint_package()
devtools::test()
devtools::build()
devtools::check()
pkgdown::build_site()
```

Tests that call YouTube skip without credentials. Set a public-data key with
`yt_set_key()` for integration tests. OAuth tests that access account data need
a usable token from `yt_oauth()`.

## Public API rules

- `list_*()` mirrors a YouTube list endpoint. `get_*()` returns a derived,
  enriched, or singular result. Write functions name the operation directly.
- Public arguments use snake case. Plural ID arguments accept vectors;
  singular ID arguments accept one value.
- `max_results` is a total result limit. Use `paginate_api_request()` for
  endpoints whose page cap is lower.
- A fixed simplified return schema uses snake-case columns and keeps those
  columns for empty results. `simplify = FALSE` returns the collected API
  response.
- `get_video_details()` may retain API-derived field names because its schema
  depends on `part`.
- Public reads default to `auth = "key"`. Functions that can read public or
  private data accept `"key"` and `"token"`. OAuth-only reads and writes do not
  expose an `auth` argument.
- Validate mutually exclusive YouTube filters before making a request.
- Do not expose an arbitrary `query` argument in a public wrapper. Name the
  supported API parameters.

The API convention and support matrix are in
`vignettes/api-conventions.Rmd`.

## HTTP and quota layers

Use `tuber_GET()`, `tuber_POST_json()`, `tuber_PUT()`, or `tuber_DELETE()` for
ordinary API requests. Media uploads may call `httr` directly when the Google
upload protocol requires a different host or body.

Every request must check the HTTP response before parsing it. Track the API
resource and method with `track_quota_usage()`. The package estimates three
session-local buckets: ordinary Data API units, Search Query calls, and Video
Upload calls. Google Cloud Console is the source of truth for project usage.

OAuth tokens default to the user's R cache directory. Never commit OAuth
tokens or API keys.

## Tests

Use `testthat::local_mocked_bindings()` or `with_mocked_bindings()` for request
assembly and response-shape tests. Correctness tests should verify the path,
query parameter names, pagination, auth choice, error class, and empty-result
schema. Do not rely on README text as evidence that a function works.

Official Google documentation is the authority for endpoint parameters,
filter combinations, upload protocols, scopes, and quotas.
