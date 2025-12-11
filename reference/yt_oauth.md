# Set up Authorization

The function looks for `.httr-oauth` in the working directory. If it
doesn't find it, it expects an application ID and a secret. If you want
to remove the existing `.httr-oauth`, set remove_old_oauth to TRUE. By
default, it is set to FALSE. The function launches a browser to allow
you to authorize the application

## Usage

``` r
yt_oauth(
  app_id = NULL,
  app_secret = NULL,
  scope = "ssl",
  token = ".httr-oauth",
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
  `upload_and_manage_own_videos`, `partner`, and `partner_audit`.
  Required. `ssl` and `basic` are basically interchangeable. Default is
  `ssl`.

- token:

  path to file containing the token. If a path is given, the function
  will first try to read from it. Default is `.httr-oauth` in the local
  directory. So if there is such a file, the function will first try to
  read from it.

- ...:

  Additional arguments passed to
  [`oauth2.0_token`](https://httr.r-lib.org/reference/oauth2.0_token.html)

## Value

sets the google_token option and also saves `.httr_oauth` in the working
directory (find out the working directory via
[`getwd()`](https://rdrr.io/r/base/getwd.html))

## Details

If a browser cannot be opened, pass `use_oob = TRUE` to `yt_oauth()` so
authentication can be completed using an out-of-band code. Delete the
`.httr-oauth` file in the working directory to force re-authentication.

## References

<https://developers.google.com/youtube/v3/docs/>

<https://developers.google.com/youtube/v3/guides/auth/client-side-web-apps>
for different scopes

## Examples

``` r
 if (FALSE) { # \dontrun{
yt_oauth(paste0("998136489867-5t3tq1g7hbovoj46dreqd6k5kd35ctjn",
                ".apps.googleusercontent.com"),
         "MbOSt6cQhhFkwETXKur-L9rN")
} # }
```
