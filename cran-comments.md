## Test environments

* local macOS 15.5 (aarch64), R 4.6.0
* GitHub Actions: ubuntu-latest (release, devel, oldrel-1), macOS-latest
  (release), windows-latest (release)

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## Release summary

This is a major release. It standardizes function and argument names, removes
wrappers for retired YouTube endpoints, corrects request filters and
pagination, and implements resumable video and caption uploads. The NEWS file
and `api-conventions` vignette document the breaking changes.

## Reverse dependencies

One package on CRAN lists tuber: bdpar, which has it in Suggests.

bdpar calls `tuber::get_comments()` in `R/ExtractorYtbid.R`. That function is
one of the names this release standardizes; it is now `list_comments()`.
bdpar's own checks continue to pass, because those call sites need YouTube
credentials and its tests exercise only an argument-validation path, but the
extractor will stop working for bdpar users until the call is renamed. The
bdpar maintainer is being notified.
