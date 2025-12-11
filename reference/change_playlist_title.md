# Change the title of a YouTube playlist.

This function updates the title of an existing YouTube playlist using
the YouTube Data API.

## Usage

``` r
change_playlist_title(playlist_id, new_title, auth = "token")
```

## Arguments

- playlist_id:

  A character string specifying the ID of the playlist you want to
  update.

- new_title:

  A character string specifying the new title for the playlist.

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

## Value

A list containing the server response after the update attempt.

## Examples

``` r
if (FALSE) { # \dontrun{
change_playlist_title(playlist_id = "YourPlaylistID", new_title = "New Playlist Title")
} # }
```
