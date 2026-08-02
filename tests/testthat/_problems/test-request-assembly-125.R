# Extracted from test-request-assembly.R:125

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "tuber", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
new_capture <- function(response) {
  captured <- new.env(parent = emptyenv())
  captured$reqs <- list()
  captured$fn <- function(path, query, ...) {
    captured$reqs[[length(captured$reqs) + 1L]] <- list(path = path, query = query)
    response
  }
  captured
}
cat_items <- function(n) {
  list(items = lapply(seq_len(n), function(i) {
    list(etag = "etag1", id = as.character(i),
         snippet = list(channelId = "UCchannel",
                        title = paste("Category", i),
                        assignable = TRUE))
  }))
}

# test -------------------------------------------------------------------------
cap <- new_capture(list(items = list()))
local_mocked_bindings(tuber_GET = cap$fn, .package = "tuber")
get_live_streams(stream_id = "S1", status = "completed")
