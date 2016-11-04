# version 0.6.0 

* video_id is returned as part of the list for get_stats, get_video_details
* handles errors stemming from bad video id for get_stats, get_video_details
* fixed bug in get_comment that delivers separate results for diff. filters, error handling for bad comment_id, and now comment_id returned as part of df 

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
