# Null coalescing operator

Returns the right-hand side if the left-hand side is NULL or has length
0.

## Usage

``` r
x %||% y
```

## Arguments

- x:

  Left-hand side value

- y:

  Right-hand side value (default if x is NULL/empty)

## Value

x if x is not NULL and has length \> 0, otherwise y

## Examples

``` r
if (FALSE) { # \dontrun{
NULL %||% "default"  # Returns "default"
"value" %||% "default"  # Returns "value"
character(0) %||% "default"  # Returns "default"
} # }
```
