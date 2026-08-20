# Paginate API requests with standardized pattern

Helper function to handle pagination for YouTube API requests
consistently. Collects items across multiple pages until max_results or
max_pages is reached.

## Usage

``` r
paginate_api_request(
  initial_response,
  fetch_next_page_fn,
  extract_items_fn = function(res) res$items,
  max_results = Inf,
  max_pages = Inf
)
```

## Arguments

- initial_response:

  The response from the initial API call

- fetch_next_page_fn:

  Function that takes a page token and returns the next page

- extract_items_fn:

  Function to extract items from a response. Default: function(res)
  res\$items

- max_results:

  Maximum number of items to collect. Default: Inf

- max_pages:

  Maximum number of pages to retrieve. Default: Inf

## Value

List with items (all collected items) and metadata
