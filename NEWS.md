# version 0.9.9.9000 (development version)

* Added support for API key authentication with two new exported functions, `yt_get_key()` and `yt_set_key()`, and a new `auth` argument to the internal function `tuber_GET()`. Users can now pass `auth = "key"` to any function that uses `tuber_GET()` to enable API key authentication. The behavior of `tuber_GET()` remains unchanged when using the new default, `auth = "token"`, which avoids breaking changes to previously written code (@gvelasq, #117).

# version 0.9.9

* added functionality like upload_video etc. see https://github.com/soodoku/tuber/commit/2cf53c50e9079af0f6b1a478698d0bda15f4c5e0
* bug fix: https://github.com/soodoku/tuber/commit/c1d6d82fe9334bb1aecbeb006521dcf99f803a88

# version 0.9.8

* allows for caption uploading
* list_my_videos
* list_captions

# version 0.9.6

* default of mine changed to NULL from FALSE thank to advice from Miguel Arribas

# version 0.9.5

* add some other util functions for getting details on all videos from a channel
* mine = TRUE

# version 0.9.4

* fix bug(s) in get_all_comments

# version 0.9.3

* A new vignette for tuber that shows how to deal with emojis in tuber
* A new function for fetching all the comments, including replies. Also fixes #43
* Added the missing partner scope fixing #41.
* New pkgdown documentation released with functions organized by purpose.
* get_related_videos returns related video id in addition to other cols.

# version 0.9.2

* fixes list_channel_videos. it used to iterate over all the playlists. You don't need to do that. All the uploaded videos of a channel are available in a playlist with the same id as channel id except the first two letters are switched.

* fixes get_playlist_items. thanks to @TebanSierra. See #39.

# version 0.9.1

* get_video_detail doesn't hardcode part = 'snippet'.
* get_playlists was trying to do argument matching w/ part which can be a comma separated list. So obviously it failed big time. Fixed now.

# version 0.9.0

* Extensive linting. Passes expect_lint_free
* Removed support for caption tracks from old Youtube API as client should only be for V3. Changed the get_captions API.
* support the deletes
* translate_filter in get_comment_threads also supports pagetoken, which it didn't.
* removes cats (prints) from get_stats based on user feedback
* list_channel_videos now supports getting all the videos from the playlists
* get_playlist_items supports simplify, defaults to simplify, and also allows getting all the videos from the playlist easily.
* get_comment_threads allows getting all the comment_threads

# version 0.8.0

* get_all --- iterate through the results and get all supported for various functions. supported for yt_search(). prints removed from yt_search()
* yt_search() for returns a data.frame with video_id when simplify is TRUE
* When a resource with a particular ID is not found, the functions now issue a warning() rather than 'cat' out the problem.

# version 0.7.0

* No more invisible return
* Rather than is.null checks, !is.character checks for args expected to be chars
* using ldly for more robust rbind of data.frames
* Specific functions:
    * get_playlists now supports simplify --- allows for data.frame return
    * More consistent return for get_related_videos() --- df with same cols. even if no results.
    * list_guidecats() and list_videocats() now return region_code as part of the returned data.frame
    * return when simplify is TRUE for yt_search() now gives a data.frame with 15 columns
    * nicer return and documentation for list_channel_activities()
    * better documentation for get_playlists()
    * fixed a bug in list_abuse_report_reasons() for part as snippet

# version 0.6.0

* Based on CRAN feedback, add comment about yt_outh to all man pages
* video_id is returned as part of the list for get_stats, get_video_details
* handles errors stemming from bad video id for get_stats, get_video_details
* fixed bug in get_comment that delivers separate results for diff. filters, error handling for bad comment_id, and now comment_id returned as part of df
* better returns when simplify is TRUE for get_related_videos, get_comment_threads
* list_caption_tracks function added. updated get_captions to only return caption related to a particular caption_id or video_id

# version 0.5.0

* Added contributor code of conduct
* yt_search takes a new argument simplify which if TRUE returns a dataframe with 7 elements. Otherwise it returns a list with all the information.

# version 0.4.0 2016-10-04

* Filtering by different facets is now supported. This is via passing a named vector.
* Added a function to list_channel_videos
* Added a function to get comment threads
* Added to the vignette an example of how to get stats of all videos of a channel.

# version 0.3.0 2016-08-04

* Replaces list_channel_videos with list_channel_resources. Returns a list.
* Supports and documents all optional params except onBehalfOfContentOwner, for list_guidecats, list_channel_activities, get_captions, list_channel_sections, get_comments, list_langs, list_regions
* Adds get_playlists, get_playlist_items, get_subscriptions, get_videos
* Renames get_channel with get_channel_stats
* Standardize argument naming to snake_case

# version 0.2.1 2016-06-20

* Support the dots --- allow for passing of extra arguments to httr GET and POST
* More tests
* Added list channel activities and list channel sections
* Get details uses the abstract infrastructure
* yt_oauth takes path to token file. removing file no longer supported

# version 0.2.0 2016-01-16

* Deprecated Freebase Topic Search
* Supports many more functions of the API. For instance, list_langs, list_guidecats, list_videocats, list_regions
* Supports more arguments for many of the functions. For instance, comments now supports maxResults, textFormat etc.
* Return defaulted to a data.frame in many of the functions
