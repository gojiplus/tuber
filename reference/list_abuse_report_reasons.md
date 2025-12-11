# List reasons that can be used to report abusive videos

List reasons that can be used to report abusive videos

## Usage

``` r
list_abuse_report_reasons(part = "id, snippet", hl = "en-US", ...)
```

## Arguments

- part:

  Caption resource requested. Required. Comma separated list of one or
  more of the following: `id, snippet`. e.g., `"id, snippet"`, `"id"`,
  etc. Default: `snippet`.

- hl:

  Language used for text values. Optional. Default is `en-US`. For other
  allowed language codes, see
  [`list_langs`](https://gojiplus.github.io/tuber/reference/list_langs.md).

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

If no results, empty data.frame returned If part requested = "id,
snippet" or "snippet", `data.frame` with 4 columns:
`etag, id, label, secReasons` If part requested = "id", data.frame with
2 columns: `etag, id`

## References

<https://developers.google.com/youtube/v3/docs/videoAbuseReportReasons/list>

## Examples

``` r
if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

list_abuse_report_reasons()
list_abuse_report_reasons(part="id")
list_abuse_report_reasons(part="snippet")
} # }
```
