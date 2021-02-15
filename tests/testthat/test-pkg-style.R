# https://github.com/jimhester/lintr
if (requireNamespace("lintr", quietly = TRUE)) {
  testthat::context("lints")
  testthat::test_that("Package Style", {
    linterPath <- getwd()
    print(linterPath)
    lintr::expect_lint_free(path = linterPath, cache = TRUE)
  })
}
