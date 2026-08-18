# Manage YouTube API key

These functions read and set YouTube keys in the current R process.

## Usage

``` r
yt_get_key(decrypt = FALSE)
yt_set_key(key, type)
```

## Arguments

- decrypt:

  Whether to decrypt \`YOUTUBE_KEY\` with \[httr2::secret_decrypt()\].
  If \`TRUE\`, \`TUBER_KEY\` must also be set.

- key:

  A character vector specifying a YouTube API key.

- type:

  Key type: \`"api"\` sets \`YOUTUBE_KEY\`; \`"package"\` sets
  \`TUBER_KEY\`, which can decrypt an encrypted API key in continuous
  integration.

## Value

\`yt_get_key()\` returns \`YOUTUBE_KEY\` invisibly, or \`NULL\` when it
is unset.

\`yt_set_key()\` sets the selected environment variable for the current
R process and invisibly returns the key. Put the variable in a
user-level \`.Renviron\` file yourself if it must persist across
sessions.

## Examples

``` r
if (FALSE) { # \dontrun{
## for interactive use
yt_get_key()

list_channel_videos(
  channel_id = "UCDgj5-mFohWZ5irWSFMFcng",
  max_results = 3,
  part = "snippet",
  auth = "key"
)

## for continuous integration and testing
yt_set_key(httr2::secret_make_key(), type = "package")
x <- httr2::secret_encrypt("YOUR_YOUTUBE_API_KEY", "TUBER_KEY")
yt_set_key(x, type = "api")
yt_get_key(decrypt = TRUE)

list_channel_videos(
  channel_id = "UCDgj5-mFohWZ5irWSFMFcng",
  max_results = 3,
  part = "snippet",
  auth = "key"
)
} # }
```
