# Live tests spend real quota and need a public-data key from yt_set_key().
skip_without_key <- function() {
  testthat::skip_on_cran()
  testthat::skip_if(identical(Sys.getenv("YOUTUBE_KEY"), ""), "YOUTUBE_KEY is not set")
}
