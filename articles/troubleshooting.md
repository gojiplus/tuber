# Troubleshooting Common Issues

## Troubleshooting Common Issues

This vignette addresses the most common issues users encounter when
setting up and using the `tuber` package.

### HTTP 403 Errors

#### Error: “YouTube Data API has not been used in project before or it is disabled”

**Cause**: The YouTube Data API v3 is not enabled in your Google Cloud
project.

**Solution**: 1. Go to [Google Cloud
Console](https://console.cloud.google.com/) 2. Select your project (or
create a new one) 3. Enable the YouTube Data API v3:
<https://console.cloud.google.com/marketplace/product/google/youtube.googleapis.com>
4. Wait 2-5 minutes for the API to be fully activated 5. Try your
request again

#### Error: “Access denied” or “Insufficient permissions”

**Cause**: Your OAuth scope or API key doesn’t have the required
permissions.

**Solution**: - For OAuth: Delete `.httr-oauth` file and re-authenticate
with
[`yt_oauth()`](https://gojiplus.github.io/tuber/reference/yt_oauth.md) -
For API keys: Ensure your API key has YouTube Data API permissions -
Some operations (like accessing private videos) require OAuth
authentication

### Authentication Issues

#### Error: “Both app_id and app_secret are required”

**Complete Setup Instructions**: 1. Go to [Google Cloud
Console](https://console.cloud.google.com/) 2. Create a new project or
select existing one 3. Enable YouTube Data API v3 4. Go to
[Credentials](https://console.cloud.google.com/apis/credentials) 5.
Click “Create Credentials” \> “OAuth client ID” 6. Choose “Desktop
application” 7. Note the Client ID and Client Secret 8. Use:
`yt_oauth("your_client_id", "your_client_secret")`

#### OAuth Browser Issues

**Issue**: Browser doesn’t open or redirect fails

**Solutions**: - Use out-of-band authentication:
`yt_oauth(app_id, app_secret, use_oob = TRUE)` - For server
environments, copy the authorization code manually - Ensure your OAuth
app is configured for “Desktop application”

### API Quota and Rate Limits

#### Error: “Quota exceeded”

**Cause**: You’ve exceeded your daily API quota (default: 10,000 units).

**Solutions**: - Wait until quota resets (daily at Pacific Time
midnight) - Request quota increase in Google Cloud Console - Use batch
operations to reduce quota usage - Cache results to avoid repeated API
calls

#### Error: “Rate limit exceeded” (429)

**Cause**: Too many requests in a short time period.

**Solution**: Add delays between requests:

``` r
# Add small delays between requests
Sys.sleep(0.1)  # 100ms delay
```

### Common Function Issues

#### get_captions() returns 403

**Cause**: Caption download requires video ownership.

**Solution**: You can only download captions from videos you own using
OAuth authentication.

#### Comments functions return fewer results than expected

**Cause**: YouTube API has built-in limits and some comments may be
hidden.

**Solutions**: - YouTube limits total searchable results (~500 for
search, varies for comments) - Some comments may be filtered by
YouTube’s spam detection - Private or deleted comments won’t appear in
results

#### Channel lookup fails

**Cause**: Channel usernames may have changed to custom URLs.

**Solution**: Use channel IDs instead of usernames when possible:

``` r
# Instead of username
get_channel_stats(channel_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw")
# Instead of 
get_channel_stats(username = "oldusername")
```

### Performance Tips

1.  **Use batch operations** for multiple videos/channels
2.  **Cache API responses** for repeated analysis
3.  **Use appropriate parts** - only request data you need
4.  **Implement retry logic** for transient failures
5.  **Monitor quota usage** with built-in tracking functions

### Getting Help

If you continue to experience issues:

1.  Check that your issue isn’t covered in this troubleshooting guide
2.  Verify your Google Cloud setup matches the instructions exactly
3.  Test with simple examples before complex operations
4.  Check the [GitHub issues](https://github.com/gojiplus/tuber/issues)
    for similar problems
5.  When reporting issues, include:
    - Complete error messages
    - Minimal reproducible example
    - Your Google Cloud project setup details (without sharing
      credentials)
