# Apply Unicode Handling to YouTube API Response

Applies consistent Unicode handling to common YouTube API response
fields

## Usage

``` r
process_youtube_text(
  response,
  text_fields = c("title", "description", "textDisplay", "textOriginal", "channelTitle",
    "authorDisplayName", "categoryId")
)
```

## Arguments

- response:

  List or data.frame containing YouTube API response data

- text_fields:

  Character vector of field names to process. Default: common YouTube
  text fields

## Value

Processed response with proper Unicode handling
