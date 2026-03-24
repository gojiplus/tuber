# Build a standardized comment data frame row

Creates a single-row data frame with standardized comment fields. Used
by get_all_comments and related functions.

## Usage

``` r
build_comment_row(snippet, comment_id, parent_id = NA_character_)
```

## Arguments

- snippet:

  The comment snippet object from YouTube API

- comment_id:

  The comment ID

- parent_id:

  Parent comment ID for replies, NA for top-level comments

## Value

A single-row data.frame with standardized columns
