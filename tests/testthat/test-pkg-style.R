# https://github.com/jimhester/lintr
if (requireNamespace("lintr", quietly = TRUE)) {
  lint_path <- path.expand(normalizePath(getwd(), winslash = "/"))

  find_root <- function(path, pkgname) {
    if ("DESCRIPTION" %in% dir(path)) {
      return(path.expand(normalizePath(path, winslash = "/")))
    } else if ("00_pkg_src" %in% dir(path)) {
      path <- file.path(path, "00_pkg_src", pkgname)
      return(path.expand(normalizePath(path, winslash = "/")))
    } else {
      find_root(dirname(path), pkgname)
    }
  }
  lint_path <- find_root(lint_path, "tuber")
  testthat::context("lints")
  testthat::test_that("Package Style", {
    lintr::expect_lint_free(path = lint_path, cache = TRUE)
  })
}
