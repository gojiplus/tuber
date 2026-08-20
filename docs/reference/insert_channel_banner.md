# Insert Channel Banner

Uploads a channel banner image to YouTube. The image must be a JPEG or
PNG. The maximum file size is 6 MB. This returns a URL that you can then
use with \`update_channel\` (if implemented) or through the standard API
to set the channel banner.

## Usage

``` r
insert_channel_banner(file, on_behalf_of_content_owner = NULL, ...)
```

## Arguments

- file:

  Character. Path to the banner image file.

- on_behalf_of_content_owner:

  Optional YouTube content-owner ID. This is only available to
  authorized YouTube content partners.

- ...:

  Ignored; retained for backward compatibility.

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
