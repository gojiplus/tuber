# Download a Caption Track

Downloads one caption track in its original format and language unless a
translation language or output format is requested. YouTube requires
OAuth authorization and permission to access the video's captions.

## Usage

``` r
download_caption(
  caption_id,
  language = NULL,
  format = NULL,
  as_raw = TRUE,
  ...
)
```

## Arguments

- caption_id:

  Caption-track ID returned by \[list_captions()\].

- language:

  Optional translation language code.

- format:

  Optional output format: \`"sbv"\`, \`"scc"\`, \`"srt"\`, \`"ttml"\`,
  or \`"vtt"\`.

- as_raw:

  If \`TRUE\`, return a raw vector; otherwise return one character
  string.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A raw vector when \`as_raw = TRUE\`; otherwise a character scalar.

## References

<https://developers.google.com/youtube/v3/docs/captions/download>

## Examples

``` r
if (FALSE) { # \dontrun{
download_caption("y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
} # }
```
