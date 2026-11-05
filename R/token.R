#' OAuth token storage and access
#'
#' The token lives in `options(google_token)` as an httr2 token, and the
#' client that minted it in `options(tuber.oauth_client)`, so an expired
#' token can be refreshed without asking the user to authenticate again.
#' Both are set by [yt_oauth()], and both are written to the cache file: an
#' access token lasts an hour, so a cached token without its client would be
#' useless in the next session.
#'
#' @name tuber-token
#' @keywords internal
NULL

.oauth_auth_url <- "https://accounts.google.com/o/oauth2/auth"
.oauth_token_url <- "https://oauth2.googleapis.com/token"

#' Build the OAuth client for a set of app credentials
#'
#' @param app_id Client ID from Google Cloud Console
#' @param app_secret Client secret from Google Cloud Console
#' @return An httr2 OAuth client
#' @keywords internal
#' @noRd
.oauth_client <- function(app_id, app_secret) {
  oauth_client(
    id = app_id,
    secret = app_secret,
    token_url = .oauth_token_url,
    name = "tuber"
  )
}

#' Is this token expired, or close enough to it?
#'
#' A token that expires while the request is in flight is no more useful
#' than one that expired an hour ago, so the last minute counts as expired.
#'
#' @param token An httr2 token
#' @return Logical
#' @keywords internal
#' @noRd
.token_expired <- function(token) {
  expires_at <- token$expires_at
  if (is.null(expires_at)) {
    return(FALSE)
  }
  as.numeric(expires_at) - as.numeric(Sys.time()) < 60
}

#' Get a usable access token, refreshing it if it has expired
#'
#' @return The bearer token as a string
#' @keywords internal
#' @noRd
yt_access_token <- function() {
  yt_check_token()
  token <- getOption("google_token")

  if (.token_expired(token) && !is.null(token$refresh_token)) {
    client <- getOption("tuber.oauth_client")
    if (is.null(client)) {
      abort(
        c(
          "The access token has expired and cannot be refreshed.",
          i = "Run `yt_oauth()` with your `app_id` and `app_secret` to authenticate again."
        ),
        class = "tuber_token_expired"
      )
    }
    token <- tryCatch(
      oauth_flow_refresh(client, refresh_token = token$refresh_token),
      error = function(e) {
        abort(
          c(
            "Could not refresh the access token.",
            x = conditionMessage(e),
            i = "Run `yt_oauth()` with your `app_id` and `app_secret` to authenticate again."
          ),
          class = "tuber_token_refresh_failed"
        )
      }
    )
    options(google_token = token)
  }

  access <- token$access_token
  if (is.null(access) || !nzchar(access)) {
    abort(
      c(
        "The stored token carries no access token.",
        i = "Run `yt_oauth()` with your `app_id` and `app_secret` to authenticate again."
      ),
      class = "tuber_token_invalid"
    )
  }
  access
}

#' Read a saved token cache, if the file holds one this version understands
#'
#' The cache is a token together with the OAuth client that minted it.
#' Anything else, including the httr `Token2.0` that tuber 2.0.0 and earlier
#' stored, is reported plainly rather than failing later with something
#' obscure about a missing access token.
#'
#' @param path Path to the token file
#' @return A list with `token` and `client`, or NULL
#' @keywords internal
#' @noRd
.read_token_file <- function(path) {
  saved <- tryCatch(
    suppressWarnings(readRDS(path)),
    error = function(e) NULL
  )
  if (is.null(saved)) {
    return(NULL)
  }
  usable <- inherits(saved, "tuber_token_cache") &&
    inherits(saved$token, "httr2_token") &&
    inherits(saved$client, "httr2_oauth_client")
  if (usable) {
    return(saved)
  }

  inform(
    c(
      paste0("The token in ", path, " was created by an older version of tuber."),
      i = "It cannot be reused. Authenticating again; the new token replaces it."
    ),
    class = "tuber_token_legacy"
  )
  NULL
}

#' Save a token and its client without overwriting httr's shared cache
#'
#' `.httr-oauth` is httr's cache name, and every httr-based package in the
#' same working directory reads it expecting httr tokens. An httr2 token there
#' would break their authentication, so refuse rather than clobber. Any other
#' path is tuber's own and is overwritten freely.
#'
#' @param token An httr2 token
#' @param client The httr2 OAuth client that minted `token`
#' @param path Path to write to
#' @return Invisibly, the path
#' @keywords internal
#' @noRd
.save_token_file <- function(token, client, path) {
  if (identical(basename(path), ".httr-oauth")) {
    abort(
      c(
        paste0(path, " is httr's shared token cache, which other packages read."),
        i = "Refusing to overwrite it. Pass a different `token` path to `yt_oauth()`."
      ),
      class = "tuber_token_would_clobber"
    )
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(
    structure(list(token = token, client = client), class = "tuber_token_cache"),
    file = path
  )
  invisible(path)
}
