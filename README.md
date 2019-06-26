
<!-- README.md is generated from README.Rmd. Please edit that file -->
:sweet\_potato: tuber: Access YouTube API via R
-----------------------------------------------

[![Travis Build Status](https://travis-ci.org/soodoku/tuber.svg?branch=master)](https://travis-ci.org/soodoku/tuber)
[![Appveyor Build status](https://ci.appveyor.com/api/projects/status/pgr0wih12gtwvvvx?svg=true)](https://ci.appveyor.com/project/soodoku/tuber) 
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/tuber)](https://cran.r-project.org/package=tuber) 
[![codecov](https://codecov.io/gh/soodoku/tuber/branch/master/graph/badge.svg)](https://codecov.io/gh/soodoku/tuber)
![](http://cranlogs.r-pkg.org/badges/grand-total/tuber)
[![Research software impact](http://depsy.org/api/package/cran/tuber/badge.svg)](http://depsy.org/package/r/tuber)
[![Github Stars](https://img.shields.io/github/stars/soodoku/tuber.svg?style=social&label=Github)](https://github.com/soodoku/tuber)


Access YouTube API via R. Get comments posted on YouTube videos, get information on how many times a video has been liked, search for videos with particular content, and much more. You can also get closed captions of videos you own. To learn more about the YouTube API, see <https://developers.google.com/youtube/v3/>.

### Installation

To get the current development version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("soodoku/tuber", build_vignettes = TRUE)
```

To get a quick overview of some important functions in tuber, check out [this article](http://soodoku.github.io/tuber/articles/tuber-ex.html). For a fun vignette about how to analyze emojis in YouTube comments, see [here](https://github.com/soodoku/tuber/blob/master/emoji_vignette/emoji_vignette.Rmd).

### Using tuber

To get going, get the application id and password from Google Developer Console (see <https://developers.google.com/youtube/v3/getting-started>). Enable all the YouTube APIs. Also enable Freebase API. Then set the application id and password via the `yt_oauth` function. For more information about YouTube OAuth, see [YouTube OAuth Guide](https://developers.google.com/youtube/v3/guides/authentication).

``` r
yt_oauth("app_id", "app_password")
```

**Note:** If you are on ubuntu, you may have to run the following before doing anything:

    httr::set_config( config( ssl_verifypeer = 0L ) )

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

**Search Videos**

``` r
yt_search("Barack Obama")
```

**Get All the Comments Including Replies**

``` r
get_all_comments(video_id = "a-UQz7fqR3w")
```

### License

Scripts are released under the [MIT License](http://opensource.org/licenses/MIT).

### Contributor Code of Conduct

The project welcomes contributions from everyone! In fact, it depends on it. To maintain this welcoming atmosphere, and to collaborate in a fun and productive way, we expect contributors to the project to abide by the [Contributor Code of Conduct](http://contributor-covenant.org/version/1/0/0/).
