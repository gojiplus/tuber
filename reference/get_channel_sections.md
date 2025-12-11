# Get channel sections

Retrieves channel sections (featured channels, playlists, etc.).

## Usage

``` r
get_channel_sections(
  channel_id = NULL,
  section_id = NULL,
  part = "snippet,contentDetails",
  simplify = TRUE,
  auth = "key",
  ...
)
```

## Arguments

- channel_id:

  Channel ID

- section_id:

  Specific section ID (optional)

- part:

  Parts to retrieve

- simplify:

  Whether to return a simplified data frame

- auth:

  Authentication method: "token" (OAuth2) or "key" (API key)

- ...:

  Additional arguments passed to tuber_GET

## Value

List or data frame with channel section information

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all sections for a channel
sections <- get_channel_sections(channel_id = "UCuAXFkgsw1L7xaCfnd5JJOw")

# Get specific section
section <- get_channel_sections(section_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw.e-Fk7vMeOn4")
} # }
```
