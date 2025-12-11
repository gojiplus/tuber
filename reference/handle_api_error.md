# Handle YouTube API errors with context-specific messages

Handle YouTube API errors with context-specific messages

## Usage

``` r
handle_api_error(
  error_response,
  context_msg = "",
  video_id = NULL,
  channel_id = NULL
)
```

## Arguments

- error_response:

  The error response from the API

- context_msg:

  Additional context for the error

- video_id:

  Video ID if applicable for better error messages

- channel_id:

  Channel ID if applicable for better error messages

## Value

Stops execution with informative error message
