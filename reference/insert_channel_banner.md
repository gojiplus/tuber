# Insert Channel Banner

Uploads a channel banner image to YouTube. The image must be a JPEG,
PNG, or GIF. The maximum file size is 6MB. This returns a URL that you
can then use with \`update_channel\` (if implemented) or through the
standard API to set the channel banner.

## Usage

``` r
insert_channel_banner(file, channel_id = NULL, ...)
```

## Arguments

- file:

  Character. Path to the banner image file.

- channel_id:

  Character. Optional. The channel to upload the banner for (needed if
  using service accounts).

- ...:

  Additional arguments passed to
  [`POST`](https://httr.r-lib.org/reference/POST.html).

## Value

A list containing the response from the API, including the \`url\` for
the banner.

## References

<https://developers.google.com/youtube/v3/docs/channelBanners/insert>

## Examples

``` r
if (FALSE) { # \dontrun{
# Set API token via yt_oauth() first

banner <- insert_channel_banner(file = "banner.jpg")
print(banner$content$url)
} # }
```
