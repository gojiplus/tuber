#' Set up Authorization
#'
#' The function reads a cached token when one exists. Otherwise, it opens the
#' system browser and asks Google to authorize the application. By default,
#' tokens are stored in the user's R cache directory rather than the project
#' directory.
#' @param app_id client id; required; no default
#' @param app_secret client secret; required; no default
#' @param scope Character. \code{ssl}, \code{basic},
#' \code{own_account_readonly}, \code{upload_and_manage_own_videos},
#' \code{channel_memberships}, \code{partner}, and \code{partner_audit}.
#' Required. \code{ssl} and \code{basic} are basically interchangeable.
#' Default is \code{ssl}.
#' @param token Path to the token cache. The default is
#' `file.path(tools::R_user_dir("tuber", "cache"), "oauth-token.rds")`.
#' @param \dots Additional arguments passed to \code{\link[httr]{oauth2.0_token}}
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
#' yt_oauth(paste0("998136489867-5t3tq1g7hbovoj46dreqd6k5kd35ctjn",
#'                 ".apps.googleusercontent.com"),
#'          "MbOSt6cQhhFkwETXKur-L9rN")
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

  # Try to read existing token first
  google_token <- NULL
  if (file.exists(token)) {
    google_token <- tryCatch({
      saved_token <- suppressWarnings(readRDS(token))
      # httr saves tokens in a list with hash as key - extract the actual token
      # Check if it's a list but not a Token object itself (Token2.0 inherits from Token)
      if (is.list(saved_token) && !inherits(saved_token, "Token2.0") && !inherits(saved_token, "Token")) {
        saved_token <- saved_token[[1]]
      }
      saved_token
    }, error = function(e) {
      warn("Unable to read existing OAuth token",
           token_file = token,
           error = e$message,
           help = "You may need to re-authenticate",
           class = "tuber_token_read_error")
      NULL
    })
  }

  # Create new token if none exists or reading failed
  if (!file.exists(token) || is.null(google_token)) {
    if (is.null(app_id) || is.null(app_secret)) {
      abort("app_id and app_secret are required for new authentication",
            have_token_file = file.exists(token),
            help = c("Get OAuth credentials from Google Cloud Console",
                     "Visit: https://console.cloud.google.com/apis/credentials"),
            class = "tuber_oauth_credentials_required")
    }

    myapp <- oauth_app("google", key = app_id, secret = app_secret)
    scope <- match.arg(scope, c(
      "ssl", "basic", "own_account_readonly",
      "upload_and_manage_own_videos", "channel_memberships",
      "partner_audit", "partner"
    ))
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

    google_token <- oauth2.0_token(oauth_endpoints("google"), myapp, scope = scope_url, ...)

    # Try to save the token for future use
    tryCatch({
      dir.create(dirname(token), recursive = TRUE, showWarnings = FALSE)
      saveRDS(google_token, file = token)
    }, error = function(e) {
      warn("Could not save OAuth token to file",
           token_file = token,
           error = e$message,
           help = "Check file permissions in working directory",
           class = "tuber_token_save_error")
    })
  }

  options(google_token = google_token)
  invisible(google_token)
}
