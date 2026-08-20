# Upload a file to a resumable session, resuming after interruptions

The second half of \[tuber_upload_session()\]. The file goes up in
chunks tagged with \`Content-Range\`. When a chunk dies in flight or
draws a 5xx, this asks YouTube how many bytes it actually kept and
continues from there rather than restarting at byte zero, which is the
whole point of the resumable protocol on a slow or unreliable
connection.

## Usage

``` r
tuber_upload_file(
  upload_url,
  file,
  type,
  chunk_size = 8 * 1024^2,
  max_tries = 5
)
```

## Arguments

- upload_url:

  Session URL from \[tuber_upload_session()\].

- file:

  Path to the file to upload.

- type:

  MIME type of `file`.

- chunk_size:

  Bytes per request. Must be a multiple of 256 KB.

- max_tries:

  Consecutive failed attempts to tolerate before giving up.

## Value

An httr2 response. The caller checks its status.

## Details

Hand-rolled because no maintained R package implements this protocol
against an arbitrary session URL: gargle handles auth and request
preparation only, and googleCloudStorageR's resumable uploader is tied
to the Cloud Storage endpoints and the googleAuthR token stack. httr2's
\`req_retry()\` cannot be used either, since resuming means sending a
\*different\* request (a shorter chunk from a new offset), not repeating
the failed one.

## References

\<https://developers.google.com/youtube/v3/guides/using_resumable_upload_protocol\>
