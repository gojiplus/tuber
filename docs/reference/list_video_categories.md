# List Video Categories

Lists video categories by region or by category ID.

## Usage

``` r
list_video_categories(
  region_code = NULL,
  category_ids = NULL,
  language = NULL,
  auth = "key",
  ...
)
```

## Arguments

- region_code:

  Optional ISO 3166-1 alpha-2 content-region code.

- category_ids:

  Optional character vector of video-category IDs.

- language:

  Optional language code for localized text.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame with one row per category and snake-case column names.

## References

<https://developers.google.com/youtube/v3/docs/videoCategories/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_video_categories(region_code = "JP")
list_video_categories(category_ids = "10")
} # }
```
