# Add Video to Playlist

Add Video to Playlist

## Usage

``` r
add_video_to_playlist(playlist_id, video_id, position = NULL, ...)
```

## Arguments

- playlist_id:

  string; Required. The ID of the playlist.

- video_id:

  string; Required. The ID of the video to add.

- position:

  numeric; Optional. The position of the video in the playlist. If not
  provided, the video will be added to the end of the playlist.

- ...:

  Additional arguments passed to
  [`tuber_POST_json`](https://gojiplus.github.io/tuber/reference/tuber_POST_json.md).

## Value

Details of the added video in the playlist.

## References

<https://developers.google.com/youtube/v3/docs/playlistItems/insert>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

add_video_to_playlist(playlist_id = "YourPlaylistID", video_id = "2_gLD1jarfU")
} # }
```
