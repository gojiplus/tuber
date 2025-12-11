# Delete a Playlist Item

Delete a Playlist Item

## Usage

``` r
delete_playlist_items(id = NULL, ...)
```

## Arguments

- id:

  String. Required. id of the playlist item that is to be deleted

- ...:

  Additional arguments passed to
  [`tuber_DELETE`](https://gojiplus.github.io/tuber/reference/tuber_DELETE.md).

## References

<https://developers.google.com/youtube/v3/docs/playlistItems/delete>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

delete_playlist_items(id = "YourPlaylistItemID")
} # }
```
