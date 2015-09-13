### :sweet_potato: tuber: Access YouTube API via R

[![GPL-3.0](http://img.shields.io/:license-gpl-blue.svg)](http://opensource.org/licenses/GPL-3.0)
[![Build Status](https://travis-ci.org/soodoku/tuber.svg?branch=master)](https://travis-ci.org/soodoku/tuber)

Access YouTube API via R.

### Installation

To get the current development version from GitHub:

```{r install}
# install.packages("devtools")
devtools::install_github("soodoku/tuber")
```

### Using tuber

To get going, get the application id and password from [https://cloud.google.com/console](https://cloud.google.com/console). Enable all the YouTube APIs. Also enable Freebase API. Then set the application id and password via the `yt_oauth` function. For more information about YouTube OAuth, see [YouTube OAuth Guide](https://developers.google.com/youtube/v3/guides/authentication).

```{r yt_oauth}
yt_oauth("app_id", "app_password")
```

**Get Statistics of a Video**

```{r get_stats}
get_stats(video_id="N708P-A45D0")
```

**Get Information About a Video**

```{r get_stats}
get_details(video_id="N708P-A45D0")
```

**Get Captions of a Video**

```{r get_captions}
get_captions(video_id="yJXTXN4xrI8")
```

**Search Videos**
```{r yt_search}
yt_search("Barack Obama")
```

**Search Videos by Topic**
Uses the [Freebase](http://freebase.com) database of topics.

```{r yt_topic_search}
yt_topic_search("Barack Obama")
```

**Get Comments**
```{r get_comments}
get_comments(video_id="N708P-A45D0")
```

#### License
Scripts are released under [GNU V3](http://www.gnu.org/licenses/gpl-3.0.en.html).

