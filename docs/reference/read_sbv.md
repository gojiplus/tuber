# Read SBV file

Read SBV file

## Usage

``` r
read_sbv(file)
```

## Arguments

- file:

  The file name of the `sbv` file

## Value

A `data.frame` with start/stop times and the text

## Examples

``` r
if (yt_authorized()) {
vids <- list_my_videos()
res <- list_captions(video_id = vids$video_id[[1]])
cap <- download_caption(res$caption_id[[1]], as_raw = FALSE)
tfile <- tempfile(fileext = ".sbv")
writeLines(cap, tfile)
x <- read_sbv(tfile)
if (requireNamespace("hms", quietly = TRUE)) {
  x$start <- hms::as_hms(x$start)
  x$stop <- hms::as_hms(x$stop)
}
}
```
