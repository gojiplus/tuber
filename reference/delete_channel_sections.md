# Delete Channel Sections

Delete a Channel Section

## Usage

``` r
delete_channel_sections(id = NULL, ...)
```

## Arguments

- id:

  Required. ID of the channel section.

- ...:

  Additional arguments passed to
  [`tuber_DELETE`](https://gojiplus.github.io/tuber/reference/tuber_DELETE.md).

## References

<https://developers.google.com/youtube/v3/docs/channelSections/delete>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

delete_channel_sections(c(channel_id = "UCRw8bIz2wMLmfgAgWm903cA"))
} # }
```
