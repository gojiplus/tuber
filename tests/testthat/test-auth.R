fake_httr2_token <- function(access_token = "abc", ...) {
  httr2::oauth_token(access_token = access_token, ...)
}

test_that("yt_oauth uses cached token when available", {
  fake_token <- fake_httr2_token()
  tf <- withr::local_tempfile(fileext = ".rds")
  saveRDS(fake_token, tf)

  with_mocked_bindings(
    oauth_flow_auth_code = function(...) stop("oauth_flow_auth_code should not be called"),
    {
      result <- yt_oauth(token = tf)
      expect_identical(result, fake_token)
      expect_identical(getOption("google_token"), fake_token)
    }
  )
})

test_that("yt_oauth saves new token when none cached", {
  fake_token <- fake_httr2_token()
  tf <- withr::local_tempfile(fileext = ".rds")

  with_mocked_bindings(
    oauth_flow_auth_code = function(...) fake_token,
    {
      result <- yt_oauth(app_id = "id", app_secret = "secret", token = tf, scope = "ssl")
      expect_identical(result, fake_token)
      expect_identical(readRDS(tf), fake_token)
    }
  )
})

test_that("yt_oauth exposes the channel-memberships scope", {
  fake_token <- fake_httr2_token()
  captured_scope <- NULL
  tf <- withr::local_tempfile(fileext = ".rds")

  with_mocked_bindings(
    oauth_flow_auth_code = function(client, scope, ...) {
      captured_scope <<- scope
      fake_token
    },
    {
      yt_oauth(
        app_id = "id",
        app_secret = "secret",
        token = tf,
        scope = "channel_memberships"
      )
    }
  )

  expect_equal(
    captured_scope,
    "https://www.googleapis.com/auth/youtube.channel-memberships.creator"
  )
})

test_that("a token cache written by httr is reported, not silently reused", {
  legacy <- structure(
    list(credentials = list(access_token = "abc"), app = NULL, endpoint = NULL),
    class = c("Token2.0", "Token")
  )
  tf <- withr::local_tempfile(fileext = ".rds")
  saveRDS(legacy, tf)
  fresh <- fake_httr2_token("fresh")

  with_mocked_bindings(
    oauth_flow_auth_code = function(...) fresh,
    {
      expect_message(
        result <- yt_oauth(app_id = "id", app_secret = "secret", token = tf),
        "older version of tuber"
      )
      expect_identical(result, fresh)
    }
  )
})

test_that("yt_oauth refuses to write into httr's shared .httr-oauth cache", {
  # .httr-oauth is httr's cache, shared with every other httr package in the
  # same working directory. Writing an httr2 token there would break them.
  tf <- file.path(withr::local_tempdir(), ".httr-oauth")

  with_mocked_bindings(
    oauth_flow_auth_code = function(...) fake_httr2_token(),
    {
      expect_error(
        yt_oauth(app_id = "id", app_secret = "secret", token = tf),
        class = "tuber_token_would_clobber"
      )
    }
  )
})

test_that("a legacy token at tuber's own path is replaced, not refused", {
  legacy <- structure(list(credentials = list(access_token = "abc")),
    class = c("Token2.0", "Token")
  )
  tf <- withr::local_tempfile(fileext = ".rds")
  saveRDS(legacy, tf)
  fresh <- fake_httr2_token("fresh")

  with_mocked_bindings(
    oauth_flow_auth_code = function(...) fresh,
    {
      suppressMessages(yt_oauth(app_id = "id", app_secret = "secret", token = tf))
      expect_identical(readRDS(tf), fresh)
    }
  )
})

test_that("an expired token is refreshed rather than re-authorized", {
  expired <- httr2::oauth_token(
    access_token = "stale",
    refresh_token = "refresh-me",
    expires_in = -1000
  )
  withr::local_options(
    google_token = expired,
    tuber.oauth_client = tuber:::.oauth_client("id", "secret")
  )

  refreshed <- fake_httr2_token("fresh")
  with_mocked_bindings(
    oauth_flow_refresh = function(client, refresh_token, ...) {
      expect_equal(refresh_token, "refresh-me")
      refreshed
    },
    {
      expect_equal(tuber:::yt_access_token(), "fresh")
      expect_identical(getOption("google_token"), refreshed)
    }
  )
})

test_that("yt_set_key validates the key type", {
  expect_error(yt_set_key("key", type = "unknown"), "type")
})
