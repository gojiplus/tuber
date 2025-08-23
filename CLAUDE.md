# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## R Package Development Commands

This is an R package providing access to the YouTube Data API v3. Use standard R package development workflow:

**Build and Check:**
```r
# Build package
devtools::build()

# Check package (R CMD check)
devtools::check()

# Install development version
devtools::install()

# Load for development
devtools::load_all()
```

**Testing:**
```r
# Run all tests
devtools::test()

# Run specific test file
testthat::test_file("tests/testthat/test-get-all-comments.R")

# Run mock tests (no API required)
testthat::test_file("tests/testthat/test-pagination-mocks.R")

# Run integration tests (requires API key)
yt_set_key("YOUR_API_KEY")
testthat::test_file("tests/testthat/test-integration-ready.R")
```

**Documentation:**
```r
# Update documentation from roxygen comments
devtools::document()

# Build pkgdown site
pkgdown::build_site()
```

## Core Architecture

### HTTP Layer (`tuber.R`)
The foundation is built on `tuber_GET`, `tuber_POST`, `tuber_DELETE` functions that handle all YouTube API communication. These functions:
- Handle authentication (OAuth2 tokens or API keys)
- Manage HTTP errors and API responses
- Include user-agent headers and proper error checking

### Dual Authentication System
Functions support two authentication methods via the `auth` parameter:
- `auth = "token"` (default): OAuth2 via `yt_oauth()`, stored in `.httr-oauth`, requires `yt_check_token()`
- `auth = "key"`: API keys via `yt_set_key()`/`yt_get_key()`, stored in `.Renviron` as `YOUTUBE_KEY`, requires `yt_check_key()`

OAuth2 is required for write operations (uploads, playlist management), while API keys work for most read operations.

### Function Categories
Functions are organized by YouTube resource types (see `_pkgdown.yml` for complete categorization):
- **Channel functions**: `get_channel_stats`, `list_channel_videos`, etc.
- **Video functions**: `get_video_details`, `get_stats`, etc.  
- **Playlist functions**: `get_playlist_items`, `create_playlist`, etc.
- **Comment functions**: `get_all_comments`, `get_comment_threads`, etc.
- **Search functions**: `yt_search`, `yt_topic_search`
- **Caption functions**: `get_captions`, `list_captions`, etc.

### Standardized Pagination Patterns

**CRITICAL**: All pagination functions follow consistent patterns after recent fixes:
- Use `nextPageToken` in while loops with proper null checks: `while (!is.null(page_token) && is.character(page_token))`
- Accumulate `res$items` arrays, not entire response objects
- Use efficient list indexing: `list[[length(list) + 1]] <- new_item` instead of `c(list, new_item)`
- Include safety breaks: `if (length(items) >= max_results) break`

**Fixed Functions**: `get_playlist_items`, `get_all_comments`, `get_comment_threads` all now use proper pagination.

### Response Processing Architecture
Functions typically follow this pattern:
1. Build query parameters with validation
2. Make initial `tuber_GET` call
3. Handle pagination if `max_results > API_limit` or equivalent
4. Apply `simplify` parameter logic to convert nested JSON to data.frames
5. Add result metadata as attributes (`total_results`, `actual_results`, `api_limit_reached`)

### YouTube API Constraints
- **Quota limits**: 10,000 units/day default, search costs 100 units each
- **Result limits**: Search ~500 items max, playlists 50/request, comments 100/request
- **Rate limiting**: Functions should handle HTTP 403/429 responses gracefully
- **Date formats**: Must use RFC 339 format (YYYY-MM-DDTHH:MM:SSZ)

### Testing Infrastructure

**Three-tier testing system:**
1. **Mock tests** (`test-pagination-mocks.R`): Test pagination logic without API calls using `with_mocked_bindings()`
2. **Unit tests** (existing files): Test basic functionality with encrypted token
3. **Integration tests** (`test-integration-ready.R`): Full API testing with user-provided API key

Tests automatically skip when authentication is unavailable. Use `yt_set_key()` for API key testing.

### Parameter Validation Patterns
Most functions validate:
- Required string parameters with `is.character()` checks
- Enumerated values with `%in%` checks  
- API-specific constraints (e.g., `max_results` ranges per endpoint)
- RFC 339 date format validation
- Video-specific parameters only when `type = "video"`

### Key Development Notes
- All API calls must go through `tuber_GET`/`tuber_POST`/`tuber_DELETE` - never call httr directly
- Functions use both httr (OAuth) and httr2 (API key) for different authentication methods
- Many functions support both simplified data.frame output and raw list output via `simplify` parameter
- When implementing new pagination, follow the standardized pattern in `yt_search.R`