This is a resubmission for version 1.4.0.
---------------------------------

## Test environments
* Mac OS (Tahoe 26.3.1), R 4.5.2 (2025-10-31)
* checked on win-builder (devel and release)
* checked on r-hub (various platforms)

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs.

## Summary of changes
This is a major revision resolving multiple GitHub issues:
- Fixed pagination logic across all functions (#107, #95, #88, #52, #33)
- Comprehensive Unicode and emoji support via `unicode_utils.R` (#79)
- Improved error handling with actionable solutions
- Added support for new endpoints (live streams, thumbnails, etc.)
- Integrated caching for static data to reduce quota usage
- Added comprehensive integration tests and vignettes
