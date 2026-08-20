# Open a resumable media upload session

YouTube's resumable protocol is two requests: a metadata POST that
returns a session URL in the Location header, then a PUT of the bytes to
that URL. This is the first half.

## Usage

``` r
tuber_upload_session(path, query, metadata, file, type)
```

## Arguments

- path:

  API endpoint path under `upload/youtube/v3`

- query:

  query list

- metadata:

  list serialized as the JSON metadata body

- file:

  path to the file that will be uploaded

- type:

  MIME type of `file`

## Value

The session URL as a string
