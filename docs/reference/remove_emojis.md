# Remove emojis from text

Removes all emoji characters from text.

## Usage

``` r
remove_emojis(text)
```

## Arguments

- text:

  Character vector to remove emojis from

## Value

Character vector with emojis removed

## Examples

``` r
remove_emojis("Hello \U0001F44B World!")
#> [1] "Hello  World!"
remove_emojis(c("No emoji", "Has \U0001F600 emoji"))
#> [1] "No emoji"   "Has  emoji"
```
