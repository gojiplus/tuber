# Change a Playlist Title

Changes a playlist title without deleting the existing description or
default language. YouTube replaces every mutable property in the
\`snippet\` part during an update, so this function retrieves and
preserves the other snippet properties first.

## Usage

``` r
change_playlist_title(
  playlist_id,
  new_title,
  on_behalf_of_content_owner = NULL,
  ...
)
```

## Arguments

- playlist_id:

  YouTube playlist ID.

- new_title:

  New playlist title.

- on_behalf_of_content_owner:

  Optional YouTube content-owner ID. This is only available to
  authorized YouTube content partners.

- ...:

  Additional arguments passed to \[list_playlists()\] and
  \[tuber_PUT()\].

## Value

The updated playlist resource.

## References

\<https://developers.google.com/youtube/v3/docs/playlists/update\>

## Examples

``` r
if (FALSE) { # \dontrun{
change_playlist_title("PLAYLIST_ID", "New Playlist Title")
} # }
```
