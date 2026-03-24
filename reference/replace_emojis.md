# Replace emojis in text

Replaces all emoji characters with a specified string.

## Usage

``` r
replace_emojis(text, replacement = "")
```

## Arguments

- text:

  Character vector to process

- replacement:

  String to replace emojis with. Default: "" (empty string)

## Value

Character vector with emojis replaced

## Examples

``` r
replace_emojis("Hello \U0001F44B World!", replacement = "[emoji]")
#> [1] "Hello [emoji] World!"
replace_emojis("Rate: \U0001F600\U0001F600\U0001F600", replacement = "*")
#> [1] "Rate: ***"
```
