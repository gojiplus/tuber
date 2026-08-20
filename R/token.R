#' OAuth token storage and access
#'
#' The token lives in `options(google_token)` as an httr2 token, and the
#' client that minted it in `options(tuber.oauth_client)`, so an expired
#' token can be refreshed without asking the user to authenticate again.
#' Both are set by [yt_oauth()].
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
        "The access token has expired and cannot be refreshed",
        help = "Run yt_oauth() again to authenticate",
        class = "tuber_token_expired"
      )
    }
    token <- tryCatch(
      oauth_flow_refresh(client, refresh_token = token$refresh_token),
      error = function(e) {
        abort(
          "Could not refresh the access token",
          error = conditionMessage(e),
          help = "Run yt_oauth() again to authenticate",
          class = "tuber_token_refresh_failed"
        )
      }
    )
    options(google_token = token)
  }

  access <- token$access_token
  if (is.null(access) || !nzchar(access)) {
    abort(
      "The stored token carries no access token",
      help = "Run yt_oauth() again to authenticate",
      class = "tuber_token_invalid"
    )
  }
  access
}

#' Read a saved token, if the file holds one this version understands
#'
#' Versions before 2.1.0 stored an httr `Token2.0`, which httr2 cannot use.
#' Those are reported plainly rather than failing later with something
#' obscure about a missing access token.
#'
#' @param path Path to the token file
#' @return An httr2 token, or NULL
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
  if (inherits(saved, "httr2_token")) {
    return(saved)
  }

  looks_like_httr <- inherits(saved, "Token2.0") || inherits(saved, "Token") ||
    (is.list(saved) && length(saved) > 0 && inherits(saved[[1]], "Token2.0"))
  if (looks_like_httr) {
    inform(
      paste0("The token in ", path, " was created by an older version of tuber."),
      help = c(
        "tuber authenticates with httr2 now, so it cannot be reused.",
        "Authenticating again; the new token replaces it."
      ),
      class = "tuber_token_legacy"
    )
  }
  NULL
}

#' Save a token without overwriting httr's shared cache
#'
#' `.httr-oauth` is httr's cache name, and every httr-based package in the
#' same working directory reads it expecting httr tokens. An httr2 token there
#' would break their authentication, so refuse rather than clobber. Any other
#' path is tuber's own and is overwritten freely.
#'
#' @param token An httr2 token
#' @param path Path to write to
#' @return Invisibly, the path
#' @keywords internal
#' @noRd
.save_token_file <- function(token, path) {
  if (identical(basename(path), ".httr-oauth")) {
    abort(
      paste0(path, " is httr's shared token cache, which other packages read"),
      help = c(
        "Refusing to overwrite it.",
        "Pass a different `token` path to yt_oauth()"
      ),
      class = "tuber_token_would_clobber"
    )
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(token, file = path)
  invisible(path)
}
