# Delete a Playlist Item

Delete a Playlist Item

## Usage

``` r
delete_playlist_item(playlist_item_id, ...)
```

## Arguments

- playlist_item_id:

  Playlist-item ID, not the video ID.

- ...:

  Additional arguments passed to \[tuber_DELETE()\].

## Value

The empty API response, invisibly.

## References

<https://developers.google.com/youtube/v3/docs/playlistItems/delete>

## Examples

``` r
if (FALSE) { # \dontrun{
delete_playlist_item("PLAYLIST_ITEM_ID")
} # }
```
