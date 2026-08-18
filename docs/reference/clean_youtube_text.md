# Clean and Normalize YouTube Text Data

Applies consistent cleaning to YouTube text fields

## Usage

``` r
clean_youtube_text(
  text,
  remove_html = TRUE,
  normalize_whitespace = TRUE,
  max_length = NULL
)
```

## Arguments

- text:

  Character vector of text to clean

- remove_html:

  Boolean. Remove HTML tags. Default: TRUE

- normalize_whitespace:

  Boolean. Normalize whitespace. Default: TRUE

- max_length:

  Integer. Maximum length (NULL for no limit). Default: NULL

## Value

Cleaned character vector
