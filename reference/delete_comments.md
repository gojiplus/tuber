# Delete a Particular Comment

Delete a Particular Comment

## Usage

``` r
delete_comments(id = NULL, ...)
```

## Arguments

- id:

  String. Required. id of the comment being retrieved

- ...:

  Additional arguments passed to
  [`tuber_DELETE`](https://gojiplus.github.io/tuber/reference/tuber_DELETE.md).

## References

<https://developers.google.com/youtube/v3/docs/comments/delete>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

delete_comments(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
} # }
```
