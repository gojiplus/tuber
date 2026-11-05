## Test environments

* local macOS 27.0.1 (aarch64), R 4.6.0
* GitHub Actions:
    * ubuntu-latest: R-devel, R 4.6.2, R 4.5.3
    * macos-latest: R 4.6.2
    * windows-latest: R 4.6.2
* R-hub, all on R-devel: windows, macos-arm64, linux

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## Release summary

This is a major release, eleven weeks after 2.0.0. It follows an audit of the
package against the YouTube Data API documentation and fixes defects that
returned wrong or incomplete results without an error: paginated functions
could skip items, misspelled arguments were silently ignored, and one error
was misreported as "comments disabled". It also completes the move from httr
to httr2 and makes interrupted uploads resume.

The release removes a small number of exports and arguments that did not work
as documented or that wrapped parameters Google has retired. The NEWS file
lists every breaking change.

## Reverse dependencies

One package on CRAN lists tuber: bdpar 3.1.0, which has it in Suggests.

bdpar uses two tuber functions. `tuber::yt_oauth(app_id, app_secret)` is
unchanged. `tuber::get_comments()` was renamed `list_comments()` in tuber
2.0.0, as noted in that submission; this release does not change it further.
I inspected bdpar's source for these calls and did not run its checks.
