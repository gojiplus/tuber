#' Set up Authorization
#'
#' The function reads a cached token when one exists. Otherwise, it opens the
#' system browser and asks Google to authorize the application. By default,
#' tokens are stored in the user's R cache directory rather than the project
#' directory.
#'
#' The cache file holds the token together with the OAuth client, including
#' the client secret, because an access token lasts an hour and can only be
#' refreshed by the client that minted it. Treat the file as a credential.
#' @param app_id client id. Required the first time; optional once a token is
#' cached.
#' @param app_secret client secret. Required the first time; optional once a
#' token is cached.
#' @param scope Character. \code{ssl}, \code{basic},
#' \code{own_account_readonly}, \code{upload_and_manage_own_videos},
#' \code{channel_memberships}, \code{partner}, and \code{partner_audit}.
#' Required. \code{ssl} and \code{basic} are basically interchangeable.
#' Default is \code{ssl}.
#' @param token Path to the token cache. The default is
#' `file.path(tools::R_user_dir("tuber", "cache"), "oauth-token.rds")`.
#' @param \dots Additional arguments passed to
#'   \code{\link[httr2]{oauth_flow_auth_code}}
#'
#' @return The OAuth token, invisibly. The function also sets the
#' `google_token` option and saves the token at `token`.
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/}
#' @references \url{https://developers.google.com/youtube/v3/guides/auth/client-side-web-apps}
#' for different scopes
#'
#' @examples
#'  \dontrun{
#' yt_oauth(
#'   "YOUR-CLIENT-ID.apps.googleusercontent.com",
#'   "YOUR-CLIENT-SECRET"
#' )
#' }

yt_oauth <- function(
  app_id = NULL,
  app_secret = NULL,
  scope = "ssl",
  token = file.path(tools::R_user_dir("tuber", "cache"), "oauth-token.rds"),
  ...
) {

  # Modern validation using checkmate
  if (!is.null(app_id)) {
    assert_character(app_id, len = 1, min.chars = 1, .var.name = "app_id")
  }

  if (!is.null(app_secret)) {
    assert_character(app_secret, len = 1, min.chars = 1, .var.name = "app_secret")
  }

  assert_choice(scope, c("ssl", "basic", "own_account_readonly",
                         "upload_and_manage_own_videos", "channel_memberships",
                         "partner", "partner_audit"),
                .var.name = "scope")
  assert_character(token, len = 1, min.chars = 1, .var.name = "token")

  cached <- if (file.exists(token)) .read_token_file(token)
  client <- if (!is.null(app_id) && !is.null(app_secret)) {
    .oauth_client(app_id, app_secret)
  } else {
    cached$client
  }

  if (is.null(cached)) {
    if (is.null(client)) {
      abort(
        c(
          "`app_id` and `app_secret` are required for new authentication.",
          i = "Create OAuth credentials at https://console.cloud.google.com/apis/credentials"
        ),
        have_token_file = file.exists(token),
        class = "tuber_oauth_credentials_required"
      )
    }

    scope_url <- switch(scope,
      ssl = "https://www.googleapis.com/auth/youtube.force-ssl",
      basic = "https://www.googleapis.com/auth/youtube",
      own_account_readonly = "https://www.googleapis.com/auth/youtube.readonly",
      upload_and_manage_own_videos = "https://www.googleapis.com/auth/youtube.upload",
      channel_memberships =
        "https://www.googleapis.com/auth/youtube.channel-memberships.creator",
      partner_audit = "https://www.googleapis.com/auth/youtubepartner-channel-audit",
      partner = "https://www.googleapis.com/auth/youtubepartner"
    )

    google_token <- oauth_flow_auth_code(
      client,
      auth_url = .oauth_auth_url,
      scope = scope_url,
      ...
    )

    # A failed save is survivable -- the token still works for this session --
    # but refusing to clobber httr's cache is deliberate and must propagate.
    # (tryCatch() matches its *last* listed handler first, so an `error =`
    # arm would swallow the specific condition; hence the explicit test.)
    saved <- tryCatch(
      .save_token_file(google_token, client, token),
      error = function(e) e
    )
    if (inherits(saved, "error")) {
      if (inherits(saved, "tuber_token_would_clobber")) {
        stop(saved)
      }
      warn(
        c(
          paste0("Could not save the OAuth token to ", token, "."),
          x = conditionMessage(saved),
          i = "The token still works for this session."
        ),
        class = "tuber_token_save_error"
      )
    }
  } else {
    google_token <- cached$token
  }

  options(google_token = google_token, tuber.oauth_client = client)
  invisible(google_token)
}
