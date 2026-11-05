# Live tests spend real quota and never run on CRAN. Public reads need a key in
# YOUTUBE_KEY; account reads need a token from yt_oauth().
skip_if_no_api_key <- function() {
  testthat::skip_on_cran()
  if (identical(Sys.getenv("YOUTUBE_KEY"), "")) {
    testthat::skip("No YouTube API key found. Set one with yt_set_key()")
  }
}

# Loads the token cached by yt_oauth() for the calling test only. Checking
# options(google_token) instead would be fooled by the fake tokens other tests
# set.
skip_if_no_oauth_token <- function(env = parent.frame()) {
  testthat::skip_on_cran()
  cache <- file.path(tools::R_user_dir("tuber", "cache"), "oauth-token.rds")
  if (!file.exists(cache)) {
    testthat::skip("No cached YouTube OAuth token. Authenticate with yt_oauth()")
  }
  withr::local_options(google_token = NULL, tuber.oauth_client = NULL, .local_envir = env)
  loaded <- tryCatch(suppressMessages(yt_oauth()), error = function(e) NULL)
  if (is.null(loaded)) {
    testthat::skip("The cached YouTube OAuth token is not usable. Run yt_oauth() again")
  }
}
