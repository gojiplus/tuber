# List of Categories That Can be Associated with Videos

List of Categories That Can be Associated with Videos

## Usage

``` r
list_videocats(filter = NULL, ...)
```

## Arguments

- filter:

  string; Required. named vector of length 1 potential names of the
  entry in the vector: `region_code`: Character. Required. Has to be a
  ISO 3166-1 alpha-2 code (see <https://www.iso.org/obp/ui/#search>)
  `category_id`: video category ID

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

data.frame with 6 columns:
`region_code, channelId, title, assignable, etag, id`

## References

<https://developers.google.com/youtube/v3/docs/videoCategories/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_videocats(c(region_code = "JP"))
list_videocats() # Will throw an error asking for a valid filter with valid region_code
} # }
```
