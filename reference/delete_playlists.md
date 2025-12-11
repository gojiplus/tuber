# Delete a Playlist

Delete a Playlist

## Usage

``` r
delete_playlists(id = NULL, ...)
```

## Arguments

- id:

  String. Required. id of the playlist that is to be deleted

- ...:

  Additional arguments passed to
  [`tuber_DELETE`](https://gojiplus.github.io/tuber/reference/tuber_DELETE.md).

## References

<https://developers.google.com/youtube/v3/docs/playlists/delete>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

delete_playlists(id = "y3ElXcEME3lSISz6izkWVT5GvxjPu8pA")
} # }
```
