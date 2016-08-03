# version .2.2 2016-08-03

* Replaces list_channel_videos with list_channel_resources. Returns a list. 
* Supports all optional params except onBehalfOfContentOwner, documents them for list_guidecats, list_channel_activities, get_captions, 
* 

# version .2.1 2016-06-20

* Support the dots --- allow for passing of extra arguments to httr GET and POST
* More tests
* Added list channel activities and list channel sections
* Get details uses the abstract infrastructure
* yt_oauth takes path to token file. removing file no longer supported

# version .2 2016-01-16

* Deprecated Freebase Topic Search
* Supports many more functions of the API. For instance, list_langs, list_guidecats, list_videocats, list_regions
* Supports more arguments for many of the functions. For instance, comments now supports maxResults, textFormat etc.
* Return defaulted to a data.frame in many of the functions
