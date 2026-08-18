# Count emojis in text

Counts the number of emoji characters in text.

## Usage

``` r
count_emojis(text)
```

## Arguments

- text:

  Character vector to count emojis in

## Value

Integer vector with emoji counts for each element

## Examples

``` r
count_emojis("Hello world")
#> [1] 0
count_emojis("Hello \U0001F44B World \U0001F30D!")
#> [1] 2
count_emojis(c("No emoji", "\U0001F600\U0001F601\U0001F602"))
#> [1] 0 3
```
