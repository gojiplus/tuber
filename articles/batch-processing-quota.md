# Batch Processing & Quota Management

## Understanding YouTube API Quotas

The YouTube Data API v3 uses a quota system to manage usage. Every
project is allocated 10,000 quota units per day by default.

### Quota Costs by Operation

Different operations have different quota costs:

| Operation           | Quota Cost  | Example Function                                                                                                                                                       |
|---------------------|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Read (list, search) | 1 unit      | [`get_video_details()`](https://gojiplus.github.io/tuber/reference/get_video_details.md), [`yt_search()`](https://gojiplus.github.io/tuber/reference/yt_search.md)     |
| Search              | 100 units   | [`yt_search()`](https://gojiplus.github.io/tuber/reference/yt_search.md)                                                                                               |
| Write (insert)      | 50 units    | [`create_playlist()`](https://gojiplus.github.io/tuber/reference/create_playlist.md), [`upload_video()`](https://gojiplus.github.io/tuber/reference/upload_video.md)   |
| Update              | 50 units    | [`update_video_metadata()`](https://gojiplus.github.io/tuber/reference/update_video_metadata.md)                                                                       |
| Delete              | 50 units    | [`delete_videos()`](https://gojiplus.github.io/tuber/reference/delete_videos.md), [`delete_comments()`](https://gojiplus.github.io/tuber/reference/delete_comments.md) |
| Upload video        | 1,600 units | [`upload_video()`](https://gojiplus.github.io/tuber/reference/upload_video.md)                                                                                         |

**Important:** Search operations
([`yt_search()`](https://gojiplus.github.io/tuber/reference/yt_search.md),
[`yt_topic_search()`](https://gojiplus.github.io/tuber/reference/yt_topic_search.md))
cost 100 units each, so you can only perform 100 searches per day with
the default quota!

### Tracking Quota Usage

tuber provides built-in quota tracking:

``` r
library(tuber)

# Check current quota usage
quota_status <- yt_get_quota_usage()
print(quota_status)

# View details
quota_status$quota_used      # Units used today
quota_status$quota_limit     # Your daily limit (default: 10,000)
quota_status$quota_remaining # Units remaining
quota_status$reset_time      # When quota resets (midnight Pacific Time)
```

### Setting Custom Quota Limits

If you’ve requested a quota increase from Google, update your limit:

``` r
# Set a custom quota limit
yt_set_quota_limit(50000)

# Reset quota tracking (e.g., after midnight)
yt_reset_quota()
```

## Authentication Strategies

tuber supports two authentication methods, each with different use
cases.

### API Key Authentication

Best for **read-only public data**: - Searching videos - Getting public
video statistics - Fetching channel information - Reading public
comments

``` r
# Set up API key (get one from Google Cloud Console)
yt_set_key("YOUR_API_KEY")

# Use API key for read operations
video_stats <- get_video_details(
  video_ids = "dQw4w9WgXcQ",
  auth = "key"
)

channel_stats <- get_channel_stats(
  channel_ids = "UCuAXFkgsw1L7xaCfnd5JJOw",
  auth = "key"
)
```

### OAuth2 Authentication

Required for: - Accessing private/unlisted content - Writing data
(creating playlists, uploading videos) - Deleting resources - Accessing
user’s own channel data

``` r
# Set up OAuth2 (opens browser for authentication)
yt_oauth("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET")

# Write operations require OAuth
create_playlist(
  title = "My New Playlist",
  description = "A collection of favorites",
  status = "private"
)

# Access your own channel's unlisted videos
list_my_videos()
```

### Which Authentication to Use?

| Task                         | API Key | OAuth2 |
|------------------------------|---------|--------|
| Search public videos         | Yes     | Yes    |
| Get public video stats       | Yes     | Yes    |
| Get public channel info      | Yes     | Yes    |
| Read public comments         | Yes     | Yes    |
| Access unlisted videos (own) | No      | Yes    |
| Access private videos (own)  | No      | Yes    |
| Create/update playlists      | No      | Yes    |
| Upload videos                | No      | Yes    |
| Delete content               | No      | Yes    |
| Manage comments              | No      | Yes    |

## Batch Processing

When working with many videos or channels, batch processing is essential
for efficiency.

### Processing Multiple Videos

``` r
# Get details for multiple videos at once
video_ids <- c("dQw4w9WgXcQ", "M7FIvfx5J10", "kJQP7kiw5Fk")

# Single API call for multiple videos (more efficient)
videos <- get_video_details(
  video_ids = video_ids,
  part = c("snippet", "statistics"),
  auth = "key"
)

# Analyze results
head(videos)
```

### Using Bulk Analysis Functions

tuber provides high-level functions for common analysis tasks:

``` r
# Comprehensive video analysis
analysis <- bulk_video_analysis(
  video_ids = video_ids,
  include_comments = FALSE,
  auth = "key"
)

# Access results
analysis$video_data    # Detailed video information
analysis$benchmarks    # Performance percentiles
analysis$summary       # Overall statistics

# Channel analysis
channel_analysis <- analyze_channel(
  channel_id = "UCuAXFkgsw1L7xaCfnd5JJOw",
  max_videos = 50,
  auth = "key"
)

# Compare multiple channels
comparison <- compare_channels(
  channel_ids = c("UC1", "UC2", "UC3"),
  metrics = c("subscriber_count", "video_count", "view_count"),
  auth = "key"
)
```

### Pagination Handling

tuber automatically handles pagination for large result sets:

``` r
# Request more items than API allows per page (50)
# tuber automatically makes multiple API calls
playlist_items <- get_playlist_items(
  playlist_id = "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf",
  max_results = 200,  # Will make 4 API calls
  auth = "key"
)

# Get many comments with automatic pagination
comments <- get_comment_threads(
  filter = c(video_id = "dQw4w9WgXcQ"),
  max_results = 500,  # Will paginate automatically
  auth = "key"
)
```

## Extracting Data from Results

YouTube API responses contain nested JSON. Here’s how to work with them.

### Using simplify = TRUE (Default)

Most functions flatten nested data into data frames:

``` r
# Get simplified output
videos <- get_video_details(
  video_ids = "dQw4w9WgXcQ",
  simplify = TRUE,
  auth = "key"
)

# Access fields directly
videos$title
videos$viewCount
videos$likeCount
videos$channelTitle
```

### Using simplify = FALSE for Complex Data

When you need the full nested structure:

``` r
# Get raw API response
videos_raw <- get_video_details(
  video_ids = "dQw4w9WgXcQ",
  simplify = FALSE,
  auth = "key"
)

# Navigate nested structure
video <- videos_raw$items[[1]]
video$snippet$title
video$snippet$thumbnails$high$url
video$statistics$viewCount
video$contentDetails$duration
```

### Common Field Access Patterns

``` r
# Video details
videos$snippet.title          # Title
videos$snippet.description    # Description
videos$statistics.viewCount   # View count
videos$statistics.likeCount   # Like count
videos$contentDetails.duration # Duration (ISO 8601)

# Channel details
channels$snippet.title           # Channel name
channels$statistics.subscriberCount
channels$statistics.videoCount
channels$brandingSettings.channel.description

# Comment extraction
comments$snippet.topLevelComment.snippet.textDisplay
comments$snippet.topLevelComment.snippet.authorDisplayName
comments$snippet.topLevelComment.snippet.likeCount
```

## Error Handling & Retries

### Using with_retry for Transient Errors

``` r
# Automatic retry with exponential backoff
result <- with_retry(
  get_video_details(video_ids = "dQw4w9WgXcQ", auth = "key"),
  max_retries = 3,
  base_delay = 1
)
```

### Handling Quota Exhaustion

``` r
# Check before making requests
quota <- yt_get_quota_usage()
if (quota$quota_remaining < 100) {
  warning("Low quota! Consider waiting until reset at: ", quota$reset_time)
}

# Wrap expensive operations
tryCatch({
  results <- yt_search(term = "R programming", max_results = 50)
}, error = function(e) {
  if (grepl("quota", e$message, ignore.case = TRUE)) {
    message("Quota exceeded. Try again after: ", yt_get_quota_usage()$reset_time)
  }
})
```

### Rate Limiting Best Practices

``` r
# Add delays between requests
video_ids <- c("id1", "id2", "id3", "id4", "id5")

results <- lapply(video_ids, function(vid) {
  Sys.sleep(0.5)  # 500ms delay between requests
  get_video_details(video_ids = vid, auth = "key")
})
```

## Caching for Performance

tuber includes built-in caching for frequently accessed data:

``` r
# Configure cache
tuber_cache_config(
  enabled = TRUE,
  max_size = 100,
  ttl = 3600  # 1 hour TTL
)

# Cached functions (no API call if recently fetched)
cats <- list_videocats_cached(auth = "key")
langs <- list_langs_cached(auth = "key")
regions <- list_regions_cached(auth = "key")
channel <- get_channel_info_cached(channel_id = "UCxyz", auth = "key")

# Check cache status
tuber_cache_info()

# Clear cache when needed
tuber_cache_clear()
```

## Practical Examples

### Example 1: Analyze a Channel’s Performance

``` r
# Full channel analysis
analysis <- analyze_channel(
  channel_id = "UCuAXFkgsw1L7xaCfnd5JJOw",
  max_videos = 100,
  auth = "key"
)

# Summary statistics
cat("Channel:", analysis$channel_info$title, "\n")
cat("Subscribers:", analysis$channel_info$subscriberCount, "\n")
cat("Average views:", analysis$performance_metrics$avg_views_per_video, "\n")
cat("Engagement rate:", analysis$performance_metrics$engagement_rate, "\n")
```

### Example 2: Trending Analysis

``` r
# Analyze trending topics
trends <- analyze_trends(
  search_terms = c("machine learning", "AI", "data science"),
  time_period = "month",
  max_results = 25,
  region_code = "US",
  auth = "key"
)

# View trend summary
print(trends$trend_summary)

# Most trending term
best_trend <- trends$trend_summary[1, ]
cat("Top trending:", best_trend$search_term, "\n")
cat("Total views:", best_trend$total_views, "\n")
```

### Example 3: Efficient Video Processing

``` r
# Get all videos from a playlist
playlist_videos <- get_playlist_items(
  playlist_id = "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf",
  max_results = 100,
  auth = "key"
)

# Extract video IDs
video_ids <- sapply(playlist_videos$items, function(x) {
  x$contentDetails$videoId
})

# Get detailed stats for all videos in one call
video_stats <- get_video_details(
  video_ids = video_ids,
  part = c("statistics", "contentDetails"),
  auth = "key"
)

# Analyze performance
total_views <- sum(as.numeric(video_stats$viewCount), na.rm = TRUE)
avg_duration <- mean(as.numeric(video_stats$duration), na.rm = TRUE)
```

## Troubleshooting

### Common Issues

**“quotaExceeded” error:** - Check quota with
[`yt_get_quota_usage()`](https://gojiplus.github.io/tuber/reference/yt_get_quota_usage.md) -
Wait until `reset_time` or request quota increase from Google

**“forbidden” error:** - Ensure YouTube Data API is enabled in Google
Cloud Console - Check API key/OAuth credentials are correct - Verify the
resource isn’t private

**“videoNotFound” or empty results:** - Video may be private, deleted,
or region-restricted - Double-check the video/channel ID format

**Rate limiting (429 errors):** - Add delays with
[`Sys.sleep()`](https://rdrr.io/r/base/Sys.sleep.html) between
requests - Use
[`with_retry()`](https://gojiplus.github.io/tuber/reference/with_retry.md)
for automatic backoff

### Getting Help

``` r
# Check function documentation
?get_video_details
?yt_search
?with_retry

# View package vignettes
browseVignettes("tuber")
```
