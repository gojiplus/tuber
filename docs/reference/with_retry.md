# Exponential backoff retry logic for API calls

Implements exponential backoff with jitter for retrying failed API calls

## Usage

``` r
with_retry(
  expr,
  max_retries = 3,
  base_delay = 1,
  max_delay = 60,
  backoff_factor = 2,
  jitter = TRUE,
  retry_on = function(e) is_transient_error(e),
  on_retry = NULL
)
```

## Arguments

- expr:

  Expression to evaluate (usually an API call)

- max_retries:

  Maximum number of retry attempts

- base_delay:

  Base delay in seconds for first retry

- max_delay:

  Maximum delay in seconds

- backoff_factor:

  Multiplier for delay between retries

- jitter:

  Whether to add random jitter to prevent thundering herd

- retry_on:

  Function that takes an error and returns TRUE if should retry

- on_retry:

  Function called on each retry attempt with attempt number and error

## Value

Result of successful expression evaluation
