# Search YouTube by Topic It uses the Freebase list of topics

Search YouTube by Topic It uses the Freebase list of topics

## Usage

``` r
yt_topic_search(topic = NULL, ...)
```

## Arguments

- topic:

  topic being searched for; required; no default

- ...:

  Additional arguments passed to
  [`tuber_GET`](https://gojiplus.github.io/tuber/reference/tuber_GET.md).

## Value

a list

## Examples

``` r
 if (FALSE) { # \dontrun{

# Set API token via yt_oauth() first

yt_topic_search(topic = "Barack Obama")
} # }
```
