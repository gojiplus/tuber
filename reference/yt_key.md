# Manage YouTube API key

These functions manage your YouTube API key and package key in
`.Renviron`.

## Usage

``` r
yt_get_key(decrypt = FALSE)
yt_set_key(key, type)
```

## Arguments

- decrypt:

  A boolean vector specifying whether to decrypt the supplied key with
  \`httr2::secret_decrypt()\`. Defaults to \`FALSE\`. If \`TRUE\`,
  requires the environment variable \`TUBER_KEY\` to be set in
  \`.Renviron\`.

- key:

  A character vector specifying a YouTube API key.

- type:

  A character vector specifying the type of API key to set. One of 'api'
  (the default, stored in \`YOUTUBE_KEY\`) or 'package'. Package keys
  are stored in \`TUBER_KEY\` and are used to decrypt API keys, for use
  in continuous integration and testing.

## Value

\`yt_get_key()\` returns a character vector with the YouTube API key
stored in \`.Renviron\`. If this value is not stored in \`.Renviron\`,
the functions return \`NULL\`.

When the \`type\` argument is set to 'api', \`yt_set_key()\` assigns a
YouTube API key to \`YOUTUBE_KEY\` in \`.Renviron\` and invisibly
returns \`NULL\`. When the \`type\` argument is set to 'package',
\`yt_set_key()\` assigns a package key to \`TUBER_KEY\` in \`.Renviron\`
and invisibly returns \`NULL\`.

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
