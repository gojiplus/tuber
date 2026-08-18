# Detect emojis in text

Checks whether text contains any emoji characters.

## Usage

``` r
has_emoji(text)
```

## Arguments

- text:

  Character vector to check for emojis

## Value

Logical vector indicating whether each element contains emojis

## Examples

``` r
has_emoji("Hello world")
#> [1] FALSE
has_emoji("Hello world! \U0001F44B")
#> [1] TRUE
has_emoji(c("No emoji", "Has emoji \U0001F600", "Also none"))
#> [1] FALSE  TRUE FALSE
```
