# Extract emojis from text

Extracts all emoji characters from text.

## Usage

``` r
extract_emojis(text)
```

## Arguments

- text:

  Character vector to extract emojis from

## Value

List of character vectors, one per input element, containing extracted
emojis. Returns empty character vector for elements without emojis.

## Examples

``` r
extract_emojis("Hello \U0001F44B World \U0001F30D!")
#> [[1]]
#> [1] "👋" "🌍"
#> 
extract_emojis(c("No emoji", "\U0001F600 \U0001F601 \U0001F602"))
#> [[1]]
#> character(0)
#> 
#> [[2]]
#> [1] "😀" "😁" "😂"
#> 
```
