# List Video-Abuse Report Reasons

List Video-Abuse Report Reasons

## Usage

``` r
list_abuse_report_reasons(
  part = c("id", "snippet"),
  language = "en-US",
  auth = "key",
  ...
)
```

## Arguments

- part:

  Character vector of resource parts.

- language:

  Language code for localized labels.

- auth:

  Authentication method, \`"key"\` or \`"token"\`.

- ...:

  Additional arguments passed to \[tuber_GET()\].

## Value

A data frame with one row per primary report reason.

## References

<https://developers.google.com/youtube/v3/docs/videoAbuseReportReasons/list>

## Examples

``` r
if (FALSE) { # \dontrun{
list_abuse_report_reasons()
} # }
```
