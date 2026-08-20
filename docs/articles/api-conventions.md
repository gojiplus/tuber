# API conventions and coverage

`tuber` uses one naming and return-value grammar across its public API.

## Function names

`list_*()` functions correspond to YouTube list endpoints. They retrieve
a collection and usually support pagination. `get_*()` functions return
a derived, enriched, or singular result. Write functions use the
operation as the verb, such as
[`create_playlist()`](https://gojiplus.github.io/tuber/reference/create_playlist.md),
[`upload_video()`](https://gojiplus.github.io/tuber/reference/upload_video.md),
[`delete_comment()`](https://gojiplus.github.io/tuber/reference/delete_comment.md),
and
[`set_video_thumbnail()`](https://gojiplus.github.io/tuber/reference/set_video_thumbnail.md).

The resource noun follows the verb. Names use full words where the API
concept is not already familiar:
[`list_video_categories()`](https://gojiplus.github.io/tuber/reference/list_video_categories.md)
rather than an abbreviation, and
[`get_video_stats()`](https://gojiplus.github.io/tuber/reference/get_video_stats.md)
rather than a generic `get_stats()`.

## Arguments

Arguments use snake case. Plural ID arguments accept vectors, while
singular ID arguments accept one value. Functions that expose several
YouTube filters require exactly one primary filter and report
conflicting combinations before making a request.

`max_results` always limits the total number of returned items. The
function may make several requests because YouTube caps individual
response pages. `page_token` selects the first page when a caller needs
to resume a previous request.

Public reads use `auth = "key"` by default. Pass `auth = "token"` when
the resource is private. Functions that always require OAuth, including
writes and owner-only reads, do not expose an `auth` choice.

## Return values

Collection functions return a data frame by default and a collected API
response when `simplify = FALSE`. Fixed simplified schemas use
snake-case columns and preserve their columns even when no rows are
returned.

[`get_video_details()`](https://gojiplus.github.io/tuber/reference/get_video_details.md)
is the deliberate exception. Its columns depend on the requested `part`
values and retain YouTube’s field names. Use `simplify = FALSE` when you
need the nested video resource or an owner-only part.

Write functions return the created or updated API resource. Upload
functions return the final HTTP response, the parsed resource, and the
relevant YouTube URL. Delete functions return the HTTP response
invisibly.

## Endpoint coverage

The table records the public wrappers in this release. It is a support
matrix, not a claim that `tuber` implements the entire YouTube API.

| Resource | Read and analysis | Write |
|----|----|----|
| Channels | [`get_channel_details()`](https://gojiplus.github.io/tuber/reference/get_channel_details.md), [`get_my_channel()`](https://gojiplus.github.io/tuber/reference/get_channel_details.md), [`list_channel_activities()`](https://gojiplus.github.io/tuber/reference/list_channel_activities.md), [`list_channel_videos()`](https://gojiplus.github.io/tuber/reference/list_channel_videos.md) | [`insert_channel_banner()`](https://gojiplus.github.io/tuber/reference/insert_channel_banner.md) |
| Channel sections | [`list_channel_sections()`](https://gojiplus.github.io/tuber/reference/list_channel_sections.md) | [`delete_channel_section()`](https://gojiplus.github.io/tuber/reference/delete_channel_section.md) |
| Videos | [`get_video_details()`](https://gojiplus.github.io/tuber/reference/get_video_details.md), [`get_video_stats()`](https://gojiplus.github.io/tuber/reference/get_video_stats.md), [`list_popular_videos()`](https://gojiplus.github.io/tuber/reference/list_popular_videos.md), [`list_my_videos()`](https://gojiplus.github.io/tuber/reference/list_my_videos.md) | [`upload_video()`](https://gojiplus.github.io/tuber/reference/upload_video.md), [`update_video_metadata()`](https://gojiplus.github.io/tuber/reference/update_video_metadata.md), [`set_video_thumbnail()`](https://gojiplus.github.io/tuber/reference/set_video_thumbnail.md), [`delete_video()`](https://gojiplus.github.io/tuber/reference/delete_video.md) |
| Playlists | [`list_playlists()`](https://gojiplus.github.io/tuber/reference/list_playlists.md), [`list_playlist_items()`](https://gojiplus.github.io/tuber/reference/list_playlist_items.md), ID helpers | [`create_playlist()`](https://gojiplus.github.io/tuber/reference/create_playlist.md), [`change_playlist_title()`](https://gojiplus.github.io/tuber/reference/change_playlist_title.md), [`add_video_to_playlist()`](https://gojiplus.github.io/tuber/reference/add_video_to_playlist.md), delete functions |
| Comments | [`list_comment_threads()`](https://gojiplus.github.io/tuber/reference/list_comment_threads.md), [`list_comments()`](https://gojiplus.github.io/tuber/reference/list_comments.md), [`get_all_comments()`](https://gojiplus.github.io/tuber/reference/get_all_comments.md) | [`post_comment()`](https://gojiplus.github.io/tuber/reference/post_comment.md), [`reply_to_comment()`](https://gojiplus.github.io/tuber/reference/reply_to_comment.md), moderation and delete functions |
| Captions | [`list_captions()`](https://gojiplus.github.io/tuber/reference/list_captions.md), [`download_caption()`](https://gojiplus.github.io/tuber/reference/download_caption.md) | [`upload_caption()`](https://gojiplus.github.io/tuber/reference/upload_caption.md), [`delete_caption()`](https://gojiplus.github.io/tuber/reference/delete_caption.md) |
| Search | [`yt_search()`](https://gojiplus.github.io/tuber/reference/yt_search.md), [`search_short_videos()`](https://gojiplus.github.io/tuber/reference/search_short_videos.md) | Not applicable |
| Live and monetization | [`list_live_broadcasts()`](https://gojiplus.github.io/tuber/reference/list_live_broadcasts.md), [`list_live_chat_messages()`](https://gojiplus.github.io/tuber/reference/list_live_chat_messages.md), [`list_super_chat_events()`](https://gojiplus.github.io/tuber/reference/list_super_chat_events.md), [`list_channel_members()`](https://gojiplus.github.io/tuber/reference/list_channel_members.md) | Not implemented |
| Subscriptions | [`list_subscriptions()`](https://gojiplus.github.io/tuber/reference/list_subscriptions.md) | Not implemented |
| Reference data | languages, regions, video categories, and abuse-report reasons | Not applicable |

The package does not currently wrap playlist images, watermarks, caption
updates, subscription mutations, or the write methods for live-streaming
resources. Google has retired related-video search and guide categories,
so this release does not expose wrappers for those endpoints.

## Renamed functions in 2.0.0

Version 2.0.0 removes ambiguous abbreviations and applies the `list_*()`
rule.

| Before 2.0.0 | 2.0.0 |
|----|----|
| `get_comments()` | [`list_comments()`](https://gojiplus.github.io/tuber/reference/list_comments.md) |
| `get_comment_threads()` | [`list_comment_threads()`](https://gojiplus.github.io/tuber/reference/list_comment_threads.md) |
| `get_playlist_items()` | [`list_playlist_items()`](https://gojiplus.github.io/tuber/reference/list_playlist_items.md) |
| `get_playlists()` | [`list_playlists()`](https://gojiplus.github.io/tuber/reference/list_playlists.md) |
| `get_subscriptions()` | [`list_subscriptions()`](https://gojiplus.github.io/tuber/reference/list_subscriptions.md) |
| `get_live_chat_messages()` | [`list_live_chat_messages()`](https://gojiplus.github.io/tuber/reference/list_live_chat_messages.md) |
| `get_super_chat_events()` | [`list_super_chat_events()`](https://gojiplus.github.io/tuber/reference/list_super_chat_events.md) |
| `get_stats()` | [`get_video_stats()`](https://gojiplus.github.io/tuber/reference/get_video_stats.md) |
| `get_channel_stats()` | [`get_channel_details()`](https://gojiplus.github.io/tuber/reference/get_channel_details.md) |
| `list_videos()` | [`list_popular_videos()`](https://gojiplus.github.io/tuber/reference/list_popular_videos.md) |
| `list_videocats()` | [`list_video_categories()`](https://gojiplus.github.io/tuber/reference/list_video_categories.md) |
| `list_langs()` | [`list_languages()`](https://gojiplus.github.io/tuber/reference/list_languages.md) |
| `get_captions()` | [`download_caption()`](https://gojiplus.github.io/tuber/reference/download_caption.md) |
