# OAuth token storage and access

The token lives in \`options(google_token)\` as an httr2 token, and the
client that minted it in \`options(tuber.oauth_client)\`, so an expired
token can be refreshed without asking the user to authenticate again.
Both are set by \[yt_oauth()\].
