# Set up Authorization

The function reads a cached token when one exists. Otherwise, it opens
the system browser and asks Google to authorize the application. By
default, tokens are stored in the user's R cache directory rather than
the project directory.

## Usage

``` r
yt_oauth(
  app_id = NULL,
  app_secret = NULL,
  scope = "ssl",
  token = file.path(tools::R_user_dir("tuber", "cache"), "oauth-token.rds"),
  ...
)
```

## Arguments

- app_id:

  client id; required; no default

- app_secret:

  client secret; required; no default

- scope:

  Character. `ssl`, `basic`, `own_account_readonly`,
  `upload_and_manage_own_videos`, `channel_memberships`, `partner`, and
  `partner_audit`. Required. `ssl` and `basic` are basically
  interchangeable. Default is `ssl`.

- token:

  Path to the token cache. The default is
  \`file.path(tools::R_user_dir("tuber", "cache"), "oauth-token.rds")\`.

- ...:

  Additional arguments passed to
  [`oauth_flow_auth_code`](https://httr2.r-lib.org/reference/req_oauth_auth_code.html)

## Value

The OAuth token, invisibly. The function also sets the \`google_token\`
option and saves the token at \`token\`.

## References

<https://developers.google.com/youtube/v3/docs/>

<https://developers.google.com/youtube/v3/guides/auth/client-side-web-apps>
for different scopes

## Examples

``` r
 if (FALSE) { # \dontrun{
yt_oauth(
  "YOUR-CLIENT-ID.apps.googleusercontent.com",
  "YOUR-CLIENT-SECRET"
)
} # }
```
