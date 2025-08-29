context("yt_oauth token caching")

test_that("yt_oauth uses cached token when available", {
  fake_token <- structure(
    list(credentials = list(access_token = "abc"), app = NULL, endpoint = NULL, params = list()),
    class = "Token2.0"
  )
  tf <- tempfile(fileext = ".rds")
  saveRDS(fake_token, tf)

  with_mocked_bindings(
    oauth2.0_token = function(...) stop("oauth2.0_token should not be called"),
    {
      result <- yt_oauth(token = tf)
      expect_identical(result, fake_token)
      expect_identical(getOption("google_token"), fake_token)
    }
  )
})

test_that("yt_oauth saves new token when none cached", {
  fake_token <- structure(
    list(credentials = list(access_token = "abc"), app = NULL, endpoint = NULL, params = list()),
    class = "Token2.0"
  )
  tf <- tempfile(fileext = ".rds")

  with_mocked_bindings(
    oauth2.0_token = function(...) fake_token,
    {
      result <- yt_oauth(app_id = "id", app_secret = "secret", token = tf, scope = "ssl")
      expect_identical(result, fake_token)
      expect_identical(readRDS(tf), fake_token)
    }
  )
})
