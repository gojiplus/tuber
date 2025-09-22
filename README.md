
<!-- README.md is generated from README.Rmd. Please edit that file -->

## :sweet\_potato: tuber: Access YouTube API via R
[![CI](https://github.com/gojiplus/tuber/actions/workflows/r.yml/badge.svg)](https://github.com/gojiplus/tuber/actions/workflows/r.yml)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/tuber)](https://cran.r-project.org/package=tuber)
![](http://cranlogs.r-pkg.org/badges/grand-total/tuber)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://gojiplus.github.io/tuber/)
[![License](https://img.shields.io/github/license/gojiplus/tuber)](https://github.com/gojiplus/tuber/blob/master/LICENSE)


Access YouTube API via R. Get comments posted on YouTube videos, get
information on how many times a video has been liked, search for videos
with particular content, and much more. You can also get closed captions
of videos you own. To learn more about the YouTube API, see
<https://developers.google.com/youtube/v3/>.

### Installation

To get the current development version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("soodoku/tuber", build_vignettes = TRUE)
```

To get a quick overview of some important functions in tuber, check out
[this article](https://gojiplus.github.io/tuber/articles/tuber-ex.html).

### Using tuber

To get going, get the application id and password from the Google
Developer Console (see
<https://developers.google.com/youtube/v3/getting-started>). Enable all
the YouTube APIs. Then set the application id and password via the
`yt_oauth` function. For more information about YouTube OAuth, see
[YouTube OAuth
Guide](https://developers.google.com/youtube/v3/guides/authentication).

``` r
yt_oauth("app_id", "app_password")
```

If your session cannot open a browser window for authentication, pass
`use_oob = TRUE` to `yt_oauth()` so that authentication can be completed
via an out-of-band code.

To force re-authentication at any time, delete the `.httr-oauth` file in
your working directory.

**Note:** If you are on ubuntu, you may have to run the following before
doing anything:

    httr::set_config(httr::config( ssl_verifypeer = 0L ) )

**Get Statistics of a Video**

``` r
get_stats(video_id = "N708P-A45D0")
```

**Get Information About a Video**

``` r
get_video_details(video_id = "N708P-A45D0")
```

**Get Captions of a Video**

``` r
get_captions(video_id = "yJXTXN4xrI8")
```

**Note**: It was previously possible to get captions for all videos that
had “Community contributions” enabled. However, since [*YouTube* removed
that option in September
2020](https://support.google.com/youtube/answer/2734796?hl=en&visit_id=638791335311528098-9183701&rd=1), the
`get_captions` function now only works for videos created with the same
account as the API credentials you use. An alternative for collecting
*YouTube* video captions is the [*youtubecaption*
package](https://github.com/jooyoungseo/youtubecaption).

**Search Videos**

``` r
yt_search("Barack Obama")
```

**Get All the Comments Including Replies**

``` r
get_all_comments(video_id = "a-UQz7fqR3w")
```

### License

Scripts are released under the [MIT
License](https://opensource.org/licenses/MIT).

### Contributor Code of Conduct

The project welcomes contributions from everyone! In fact, it depends on
it. To maintain this welcoming atmosphere, and to collaborate in a fun
and productive way, we expect contributors to the project to abide by
the [Contributor Code of
Conduct](https://www.contributor-covenant.org/version/1/0/0/).
