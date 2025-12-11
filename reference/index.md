# Package index

## Package Documentation

Overall package documentation

- [`tuber`](https://gojiplus.github.io/tuber/reference/tuber.md) :

  tuber provides access to the YouTube API V3.

## Authentication

Functions for authentication with the YouTube API

- [`yt_oauth()`](https://gojiplus.github.io/tuber/reference/yt_oauth.md)
  : Set up Authorization
- [`yt_token()`](https://gojiplus.github.io/tuber/reference/yt_token.md)
  [`yt_authorized()`](https://gojiplus.github.io/tuber/reference/yt_token.md)
  [`yt_check_token()`](https://gojiplus.github.io/tuber/reference/yt_token.md)
  : Check if authentication token is in options
- [`yt_get_key()`](https://gojiplus.github.io/tuber/reference/yt_key.md)
  [`yt_set_key()`](https://gojiplus.github.io/tuber/reference/yt_key.md)
  : Manage YouTube API key
- [`tuber_check()`](https://gojiplus.github.io/tuber/reference/tuber_check.md)
  : Request Response Verification

## Channel Functions

Functions for working with YouTube channels

- [`get_channel_stats()`](https://gojiplus.github.io/tuber/reference/get_channel_stats.md)
  [`list_my_channel()`](https://gojiplus.github.io/tuber/reference/get_channel_stats.md)
  : Get Channel Statistics
- [`get_subscriptions()`](https://gojiplus.github.io/tuber/reference/get_subscriptions.md)
  : Get Subscriptions
- [`list_channel_resources()`](https://gojiplus.github.io/tuber/reference/list_channel_resources.md)
  : Returns List of Requested Channel Resources
- [`list_channel_sections()`](https://gojiplus.github.io/tuber/reference/list_channel_sections.md)
  : List Channel Sections
- [`delete_channel_sections()`](https://gojiplus.github.io/tuber/reference/delete_channel_sections.md)
  : Delete Channel Sections
- [`list_channel_activities()`](https://gojiplus.github.io/tuber/reference/list_channel_activities.md)
  : List Channel Activity
- [`list_channel_videos()`](https://gojiplus.github.io/tuber/reference/list_channel_videos.md)
  : Returns List of Requested Channel Videos
- [`get_all_channel_video_stats()`](https://gojiplus.github.io/tuber/reference/get_all_channel_video_stats.md)
  : Get statistics on all the videos in a Channel

## Video Functions

Functions for working with YouTube videos

- [`get_stats()`](https://gojiplus.github.io/tuber/reference/get_stats.md)
  : Get statistics of a Video or Videos
- [`get_video_details()`](https://gojiplus.github.io/tuber/reference/get_video_details.md)
  : Get Video Details
- [`get_related_videos()`](https://gojiplus.github.io/tuber/reference/get_related_videos.md)
  : Get Related Videos
- [`list_videos()`](https://gojiplus.github.io/tuber/reference/list_videos.md)
  : List (Most Popular) Videos
- [`list_my_videos()`](https://gojiplus.github.io/tuber/reference/list_my_videos.md)
  : List My videos
- [`upload_video()`](https://gojiplus.github.io/tuber/reference/upload_video.md)
  : Upload Video to Youtube
- [`update_video_metadata()`](https://gojiplus.github.io/tuber/reference/update_video_metadata.md)
  : Update a YouTube Video's Metadata
- [`delete_videos()`](https://gojiplus.github.io/tuber/reference/delete_videos.md)
  : Delete a Video

## Playlist Functions

Functions for working with playlists

- [`get_playlists()`](https://gojiplus.github.io/tuber/reference/get_playlists.md)
  : Get Playlists
- [`get_playlist_items()`](https://gojiplus.github.io/tuber/reference/get_playlist_items.md)
  : Get Playlist Items
- [`get_playlist_item_ids()`](https://gojiplus.github.io/tuber/reference/get_playlist_item_ids.md)
  : Get Playlist Item IDs
- [`get_playlist_item_videoids()`](https://gojiplus.github.io/tuber/reference/get_playlist_item_videoids.md)
  : Get Playlist Item Video IDs
- [`create_playlist()`](https://gojiplus.github.io/tuber/reference/create_playlist.md)
  : Create New Playlist
- [`add_video_to_playlist()`](https://gojiplus.github.io/tuber/reference/add_video_to_playlist.md)
  : Add Video to Playlist
- [`change_playlist_title()`](https://gojiplus.github.io/tuber/reference/change_playlist_title.md)
  : Change the title of a YouTube playlist.
- [`delete_playlist_items()`](https://gojiplus.github.io/tuber/reference/delete_playlist_items.md)
  : Delete a Playlist Item
- [`delete_playlists()`](https://gojiplus.github.io/tuber/reference/delete_playlists.md)
  : Delete a Playlist

## Caption Functions

Functions for working with captions

- [`get_captions()`](https://gojiplus.github.io/tuber/reference/get_captions.md)
  : Get Particular Caption Track
- [`list_captions()`](https://gojiplus.github.io/tuber/reference/list_captions.md)
  : List Captions for YouTube Video
- [`list_caption_tracks()`](https://gojiplus.github.io/tuber/reference/list_caption_tracks.md)
  : List Captions of a Video
- [`upload_caption()`](https://gojiplus.github.io/tuber/reference/upload_caption.md)
  : Upload Video Caption to Youtube
- [`delete_captions()`](https://gojiplus.github.io/tuber/reference/delete_captions.md)
  : Delete a Particular Caption Track
- [`read_sbv()`](https://gojiplus.github.io/tuber/reference/read_sbv.md)
  : Read SBV file

## Comment Functions

Functions for working with comments

- [`get_comment_threads()`](https://gojiplus.github.io/tuber/reference/get_comment_threads.md)
  : Get Comments Threads
- [`get_comments()`](https://gojiplus.github.io/tuber/reference/get_comments.md)
  : Get Comments
- [`get_all_comments()`](https://gojiplus.github.io/tuber/reference/get_all_comments.md)
  : Get all the comments for a video including replies
- [`delete_comments()`](https://gojiplus.github.io/tuber/reference/delete_comments.md)
  : Delete a Particular Comment

## Search Functions

Functions for searching YouTube

- [`yt_search()`](https://gojiplus.github.io/tuber/reference/yt_search.md)
  : Search YouTube
- [`yt_topic_search()`](https://gojiplus.github.io/tuber/reference/yt_topic_search.md)
  : Search YouTube by Topic It uses the Freebase list of topics

## Additional Resources

Functions for getting YouTube metadata

- [`list_guidecats()`](https://gojiplus.github.io/tuber/reference/list_guidecats.md)
  : Get list of categories that can be associated with YouTube channels
- [`list_langs()`](https://gojiplus.github.io/tuber/reference/list_langs.md)
  : List Languages That YouTube Currently Supports
- [`list_regions()`](https://gojiplus.github.io/tuber/reference/list_regions.md)
  : List Content Regions That YouTube Currently Supports
- [`list_videocats()`](https://gojiplus.github.io/tuber/reference/list_videocats.md)
  : List of Categories That Can be Associated with Videos
- [`list_abuse_report_reasons()`](https://gojiplus.github.io/tuber/reference/list_abuse_report_reasons.md)
  : List reasons that can be used to report abusive videos

## Quota Management

Functions for tracking and managing YouTube API quota usage

- [`quota_management`](https://gojiplus.github.io/tuber/reference/quota_management.md)
  : YouTube API Quota Management
- [`yt_get_quota_usage()`](https://gojiplus.github.io/tuber/reference/yt_get_quota_usage.md)
  : Get Current Quota Usage
- [`yt_reset_quota()`](https://gojiplus.github.io/tuber/reference/yt_reset_quota.md)
  : Reset Quota Counter
- [`yt_set_quota_limit()`](https://gojiplus.github.io/tuber/reference/yt_set_quota_limit.md)
  : Set Quota Limit

## Bulk Analysis

Functions for processing multiple items efficiently

- [`bulk_video_analysis()`](https://gojiplus.github.io/tuber/reference/bulk_video_analysis.md)
  : Bulk video performance analysis

## Extended Features

Advanced analysis and specialized functions

- [`analyze_channel()`](https://gojiplus.github.io/tuber/reference/analyze_channel.md)
  : Comprehensive channel analysis
- [`analyze_trends()`](https://gojiplus.github.io/tuber/reference/analyze_trends.md)
  : Trending analysis for search terms
- [`compare_channels()`](https://gojiplus.github.io/tuber/reference/compare_channels.md)
  : Compare multiple channels
- [`get_live_streams()`](https://gojiplus.github.io/tuber/reference/get_live_streams.md)
  : Get live stream information
- [`get_premiere_info()`](https://gojiplus.github.io/tuber/reference/get_premiere_info.md)
  : Get video premiere information
- [`search_shorts()`](https://gojiplus.github.io/tuber/reference/search_shorts.md)
  : Search for shorts (YouTube Shorts)

## Caching & Performance

Functions for caching and performance optimization

- [`tuber_cache_config()`](https://gojiplus.github.io/tuber/reference/tuber_cache_config.md)
  : Configure caching settings
- [`tuber_cache_clear()`](https://gojiplus.github.io/tuber/reference/tuber_cache_clear.md)
  : Clear cache entries
- [`tuber_cache_info()`](https://gojiplus.github.io/tuber/reference/tuber_cache_info.md)
  : Get current cache configuration
- [`tuber_GET_cached()`](https://gojiplus.github.io/tuber/reference/tuber_GET_cached.md)
  : Cached version of tuber_GET with automatic caching
- [`get_channel_info_cached()`](https://gojiplus.github.io/tuber/reference/get_channel_info_cached.md)
  : Get channel information with caching (for static parts)
- [`list_langs_cached()`](https://gojiplus.github.io/tuber/reference/list_langs_cached.md)
  : List supported languages with caching
- [`list_regions_cached()`](https://gojiplus.github.io/tuber/reference/list_regions_cached.md)
  : List supported regions with caching
- [`list_videocats_cached()`](https://gojiplus.github.io/tuber/reference/list_videocats_cached.md)
  : Enhanced versions of static data functions with caching
- [`get_channel_sections()`](https://gojiplus.github.io/tuber/reference/get_channel_sections.md)
  : Get channel sections
- [`get_video_thumbnails()`](https://gojiplus.github.io/tuber/reference/get_video_thumbnails.md)
  : Get video thumbnails information
- [`with_retry()`](https://gojiplus.github.io/tuber/reference/with_retry.md)
  : Exponential backoff retry logic for API calls

## Utility Functions

Additional utility functions and information

- [`tuber_info()`](https://gojiplus.github.io/tuber/reference/tuber_info.md)
  : Display tuber function metadata
- [`list_captions()`](https://gojiplus.github.io/tuber/reference/list_captions.md)
  : List Captions for YouTube Video

## Developer & Advanced Functions

Advanced functions and low-level utilities

- [`call_api_with_retry()`](https://gojiplus.github.io/tuber/reference/call_api_with_retry.md)
  : Wrapper for tuber API calls with built-in retry logic
- [`handle_api_error()`](https://gojiplus.github.io/tuber/reference/handle_api_error.md)
  : Handle YouTube API errors with context-specific messages
- [`handle_network_error()`](https://gojiplus.github.io/tuber/reference/handle_network_error.md)
  : Handle network/connection errors with retry suggestions
- [`is_transient_error()`](https://gojiplus.github.io/tuber/reference/is_transient_error.md)
  : Check if an error is transient and worth retrying
- [`suggest_solution()`](https://gojiplus.github.io/tuber/reference/suggest_solution.md)
  : Provide helpful suggestions for common user errors
- [`warn_deprecated()`](https://gojiplus.github.io/tuber/reference/warn_deprecated.md)
  : Warn about deprecated functionality with migration guidance
- [`tuber_PUT()`](https://gojiplus.github.io/tuber/reference/tuber_PUT.md)
  : PUT
- [`print(`*`<tuber_result>`*`)`](https://gojiplus.github.io/tuber/reference/print.tuber_result.md)
  : Print method for tuber results
- [`validate_character()`](https://gojiplus.github.io/tuber/reference/validate_character.md)
  : Validate required character parameters
- [`validate_choice()`](https://gojiplus.github.io/tuber/reference/validate_choice.md)
  : Validate that parameter matches allowed values
- [`validate_numeric()`](https://gojiplus.github.io/tuber/reference/validate_numeric.md)
  : Validate numeric parameters with range checking
- [`validate_video_id()`](https://gojiplus.github.io/tuber/reference/validate_video_id.md)
  : Validate YouTube-specific IDs and parameters
- [`validate_channel_id()`](https://gojiplus.github.io/tuber/reference/validate_channel_id.md)
  : Validate YouTube channel ID format
- [`validate_playlist_id()`](https://gojiplus.github.io/tuber/reference/validate_playlist_id.md)
  : Validate YouTube playlist ID format
- [`validate_rfc3339_date()`](https://gojiplus.github.io/tuber/reference/validate_rfc3339_date.md)
  : Validate RFC 3339 date format for YouTube API
- [`validate_part_parameter()`](https://gojiplus.github.io/tuber/reference/validate_part_parameter.md)
  : Validate YouTube API part parameters
- [`validate_region_code()`](https://gojiplus.github.io/tuber/reference/validate_region_code.md)
  : Validate region codes
- [`validate_language_code()`](https://gojiplus.github.io/tuber/reference/validate_language_code.md)
  : Validate language codes
- [`validate_youtube_params()`](https://gojiplus.github.io/tuber/reference/validate_youtube_params.md)
  : Comprehensive parameter validation for YouTube API functions
- [`generate_cache_key()`](https://gojiplus.github.io/tuber/reference/generate_cache_key.md)
  : Generate cache key for API request
- [`get_cached_response()`](https://gojiplus.github.io/tuber/reference/get_cached_response.md)
  : Get cached response if available and valid
- [`store_cached_response()`](https://gojiplus.github.io/tuber/reference/store_cached_response.md)
  : Store response in cache
- [`is_cacheable_endpoint()`](https://gojiplus.github.io/tuber/reference/is_cacheable_endpoint.md)
  : Check if endpoint should be cached
- [`is_static_query()`](https://gojiplus.github.io/tuber/reference/is_static_query.md)
  : Check if query parameters indicate static data

## Documentation Topics

Package documentation and function groups

- [`extended-endpoints`](https://gojiplus.github.io/tuber/reference/extended-endpoints.md)
  : Extended YouTube API Endpoints
- [`helper-functions`](https://gojiplus.github.io/tuber/reference/helper-functions.md)
  : Helper Functions for Common YouTube Analysis Tasks
- [`caching`](https://gojiplus.github.io/tuber/reference/caching.md) :
  Response Caching for YouTube API
- [`error-handling`](https://gojiplus.github.io/tuber/reference/error-handling.md)
  : Tuber Error Handling Utilities
- [`` `%||%` ``](https://gojiplus.github.io/tuber/reference/null-coalesce.md)
  : Null coalescing operator

## Helper Functions

Internal helper functions

- [`tuber_DELETE()`](https://gojiplus.github.io/tuber/reference/tuber_DELETE.md)
  : DELETE
- [`tuber_GET()`](https://gojiplus.github.io/tuber/reference/tuber_GET.md)
  : GET
- [`tuber_POST()`](https://gojiplus.github.io/tuber/reference/tuber_POST.md)
  : POST
- [`tuber_POST_json()`](https://gojiplus.github.io/tuber/reference/tuber_POST_json.md)
  : POST encoded in json
- [`unicode_utils`](https://gojiplus.github.io/tuber/reference/unicode_utils.md)
  : Unicode and Text Processing Utilities
