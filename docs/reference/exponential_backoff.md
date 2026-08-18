# Add Exponential Backoff

Internal function to handle rate limiting with exponential backoff

## Usage

``` r
exponential_backoff(attempt_number, max_attempts = 5, base_delay = 1)
```

## Arguments

- attempt_number:

  Integer. Current attempt number

- max_attempts:

  Integer. Maximum attempts before giving up

- base_delay:

  Numeric. Base delay in seconds
