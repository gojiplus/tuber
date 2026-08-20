# Build a request against the YouTube Data API

One place where the base URL, credentials, user agent and error policy
are set, so every verb below differs only in method and body.

## Usage

``` r
tuber_request(path, query = list(), auth = "token", prefix = "youtube/v3")
```

## Arguments

- path:

  API endpoint path (e.g., "videos", "channels")

- query:

  Named list of query parameters

- auth:

  Either `"token"` for OAuth or `"key"` for an API key

- prefix:

  Path prefix. Media uploads live under `upload/youtube/v3` rather than
  `youtube/v3`.

## Value

An httr2 request object ready for method-specific modifications
