# tuber

[![R-CMD-check](https://github.com/gojiplus/tuber/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/gojiplus/tuber/actions/workflows/R-CMD-check.yml)
[![CRAN status](https://www.r-pkg.org/badges/version/tuber)](https://cran.r-project.org/package=tuber)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/tuber)](https://cran.r-project.org/package=tuber)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://gojiplus.github.io/tuber/)

`tuber` is an R client for the YouTube Data API and selected YouTube Live
Streaming API endpoints. It searches public YouTube data, retrieves channels,
videos, playlists, comments, and captions, and supports common authenticated
operations such as uploads, comment moderation, and playlist changes.

The package does not wrap every YouTube endpoint. Run
`vignette("api-conventions", package = "tuber")` for the supported resources
and known omissions.

## Installation

Install the CRAN release:

```r
install.packages("tuber")
```

Install the development version from GitHub:

```r
# install.packages("pak")
pak::pak("gojiplus/tuber")
```

## Authentication

Public read functions use an API key by default. Create a key in Google Cloud,
enable the YouTube Data API v3 for that project, and set the key for the current
R session:

```r
yt_set_key("YOUR_YOUTUBE_API_KEY")
```

OAuth is required for private account data and every operation that changes
YouTube data. Create a desktop OAuth client in Google Cloud, then authenticate
in the system browser:

```r
yt_oauth("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET")
```

`yt_oauth()` stores its token in the user's R cache directory by default. Pass
an explicit `token` path if you need a different location.

## Examples

Search for videos:

```r
videos <- yt_search("Barack Obama", max_results = 25)
```

Retrieve fixed, snake-case video statistics:

```r
stats <- get_video_stats("N708P-A45D0")
```

List a channel's playlists and the videos in one playlist:

```r
playlists <- list_playlists(channel_id = "UCMtFAi84ehTSYSE9XoHefig")
items <- list_playlist_items(
  playlist_id = playlists$playlist_id[[1]],
  max_results = 100
)
```

Collect top-level comments and all replies:

```r
comments <- get_all_comments("a-UQz7fqR3w", max_results = 500)
```

List and download caption tracks for a video owned by the authenticated
account:

```r
tracks <- list_captions("yJXTXN4xrI8")
caption <- download_caption(tracks$caption_id[[1]], as_raw = FALSE)
```

## API conventions

- `list_*()` functions mirror YouTube list endpoints and return a data frame by
  default. Use `simplify = FALSE` to keep the collected API response.
- `get_*()` functions return a derived, enriched, or singular result.
- Plural ID arguments accept vectors. Singular ID arguments accept one value.
- `max_results` is the total result limit, even when the function makes several
  paginated requests.
- Fixed simplified schemas use snake-case column names. The columns returned by
  `get_video_details()` depend on `part` and retain YouTube's field names.
- Public reads default to `auth = "key"`. Functions that can use either form of
  authentication accept `auth = "key"` or `auth = "token"`. OAuth-only
  functions do not expose an `auth` argument.

## License

`tuber` is released under the [MIT License](LICENSE).
