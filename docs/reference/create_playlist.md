# Create New Playlist

Create New Playlist

## Usage

``` r
create_playlist(title, description = "", status = "public", ...)
```

## Arguments

- title:

  string; Required. The title of the playlist.

- description:

  string; Optional. The description of the playlist.

- status:

  string; Optional. Default: 'public'. Can be one of: 'private',
  'public', or 'unlisted'.

- ...:

  Additional arguments passed to
  [`tuber_POST`](https://gojiplus.github.io/tuber/reference/tuber_POST.md).

## Value

The created playlist's details.

## References

<https://developers.google.com/youtube/v3/docs/playlists/insert>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

create_playlist(title = "My New Playlist", description = "This is a test playlist.")
} # }
```
