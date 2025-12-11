# ==============================================================================
# Tests for YouTube Channel Functions
# ==============================================================================
# This file tests all channel-related functions including:
# - get_all_channel_video_stats() - Get statistics for all videos in a channel
# - list_channel_resources() - Get channel information and playlists
# - get_playlist_items() - Used internally by channel stats functions
# 
# Tests use accurate YouTube API v3 mocks that reflect current API behavior:
# - dislikeCount is private since December 2021
# - Proper response structure with kind, etag, pageInfo fields
# ==============================================================================

test_that("get_all_channel_video_stats handles video details correctly", {
  # Mock the required functions
  with_mocked_bindings(
    # Mock list_channel_resources
    list_channel_resources = function(...) {
      list(
        kind = "youtube#channelListResponse",
        etag = "test-etag",
        pageInfo = list(
          totalResults = 1,
          resultsPerPage = 1
        ),
        items = list(
          list(
            kind = "youtube#channel",
            etag = "channel-etag",
            id = "UCad-_hTvV-yBPcpy9jwQWeA",
            contentDetails = list(
              relatedPlaylists = list(
                uploads = "UUad-_hTvV-yBPcpy9jwQWeA",
                likes = "",
                watchHistory = "HL",
                watchLater = "WL"
              )
            )
          )
        )
      )
    },
    
    # Mock get_playlist_items to return 2 video IDs
    get_playlist_items = function(...) {
      list(
        kind = "youtube#playlistItemListResponse",
        etag = "test-etag",
        pageInfo = list(
          totalResults = 2,
          resultsPerPage = 2
        ),
        items = list(
          list(
            kind = "youtube#playlistItem",
            etag = "item1-etag",
            contentDetails = list(
              videoId = "video1",
              videoPublishedAt = "2024-01-01T00:00:00Z"
            )
          ),
          list(
            kind = "youtube#playlistItem",
            etag = "item2-etag",
            contentDetails = list(
              videoId = "video2",
              videoPublishedAt = "2024-01-02T00:00:00Z"
            )
          )
        ),
        nextPageToken = NULL
      )
    },
    
    # Mock tuber_GET for video stats and details
    tuber_GET = function(path, query, ...) {
      if (grepl("statistics", query$part)) {
        # Return stats for videos (note: dislikeCount is private since Dec 2021)
        list(
          kind = "youtube#videoListResponse",
          etag = "test-etag",
          pageInfo = list(
            totalResults = 2,
            resultsPerPage = 2
          ),
          items = list(
            list(
              kind = "youtube#video",
              etag = "video1-etag",
              id = "video1",
              statistics = list(
                viewCount = "1000",
                likeCount = "100",
                # dislikeCount removed - private since Dec 2021
                commentCount = "50"
              )
            ),
            list(
              kind = "youtube#video",
              etag = "video2-etag",
              id = "video2",
              statistics = list(
                viewCount = "2000",
                likeCount = "200",
                # dislikeCount removed - private since Dec 2021
                commentCount = "100"
              )
            )
          )
        )
      } else if (grepl("snippet", query$part)) {
        # Return details for videos
        list(
          kind = "youtube#videoListResponse",
          etag = "test-etag",
          pageInfo = list(
            totalResults = 2,
            resultsPerPage = 2
          ),
          items = list(
            list(
              kind = "youtube#video",
              etag = "video1-etag",
              id = "video1",
              snippet = list(
                publishedAt = "2024-01-01T00:00:00Z",
                channelId = "UCad-_hTvV-yBPcpy9jwQWeA",
                title = "Test Video 1",
                description = "Test description 1",
                channelTitle = "Test Channel"
              )
            ),
            list(
              kind = "youtube#video",
              etag = "video2-etag",
              id = "video2",
              snippet = list(
                publishedAt = "2024-01-02T00:00:00Z",
                channelId = "UCad-_hTvV-yBPcpy9jwQWeA",
                title = "Test Video 2",
                description = "Test description 2",
                channelTitle = "Test Channel"
              )
            )
          )
        )
      }
    },
    
    {
      # Test the function
      result <- get_all_channel_video_stats(channel_id = "UCad-_hTvV-yBPcpy9jwQWeA")
      
      # Verify the result structure
      expect_true(is.data.frame(result))
      expect_equal(nrow(result), 2)
      
      # Check column names (note: dislike_count may be present but NA)
      expected_cols <- c("id", "title", "publication_date", "description", 
                        "channel_id", "channel_title", "view_count", 
                        "like_count", "comment_count", "url")
      expect_true(all(expected_cols %in% names(result)))
      # dislike_count column may exist but should be NA (private since Dec 2021)
      if ("dislike_count" %in% names(result)) {
        expect_true(all(is.na(result$dislike_count)))
      }
      
      # Verify data integrity
      expect_equal(result$id[1], "video1")
      expect_equal(result$id[2], "video2")
      expect_equal(result$title[1], "Test Video 1")
      expect_equal(result$title[2], "Test Video 2")
      expect_equal(result$publication_date[1], "2024-01-01T00:00:00Z")
      expect_equal(result$publication_date[2], "2024-01-02T00:00:00Z")
      expect_equal(result$view_count[1], "1000")
      expect_equal(result$view_count[2], "2000")
      
      # Check URL generation
      expect_equal(result$url[1], "https://www.youtube.com/watch?v=video1")
      expect_equal(result$url[2], "https://www.youtube.com/watch?v=video2")
    }
  )
})

test_that("get_all_channel_video_stats handles missing publishedAt field", {
  # Mock setup with video missing publishedAt
  with_mocked_bindings(
    list_channel_resources = function(...) {
      list(
        kind = "youtube#channelListResponse",
        etag = "test-etag",
        pageInfo = list(
          totalResults = 1,
          resultsPerPage = 1
        ),
        items = list(
          list(
            kind = "youtube#channel",
            etag = "channel-etag",
            id = "UCtest",
            contentDetails = list(
              relatedPlaylists = list(
                uploads = "UUtest",
                likes = "",
                watchHistory = "HL",
                watchLater = "WL"
              )
            )
          )
        )
      )
    },
    
    get_playlist_items = function(...) {
      list(
        kind = "youtube#playlistItemListResponse",
        etag = "test-etag",
        pageInfo = list(
          totalResults = 1,
          resultsPerPage = 1
        ),
        items = list(
          list(
            kind = "youtube#playlistItem",
            etag = "item1-etag",
            contentDetails = list(
              videoId = "video1",
              videoPublishedAt = "2024-01-01T00:00:00Z"
            )
          )
        ),
        nextPageToken = NULL
      )
    },
    
    tuber_GET = function(path, query, ...) {
      if (grepl("statistics", query$part)) {
        list(
          kind = "youtube#videoListResponse",
          etag = "test-etag",
          pageInfo = list(
            totalResults = 1,
            resultsPerPage = 1
          ),
          items = list(
            list(
              kind = "youtube#video",
              etag = "video1-etag",
              id = "video1",
              statistics = list(
                viewCount = "1000",
                likeCount = "100",
                # dislikeCount removed - private since Dec 2021
                commentCount = "25"
              )
            )
          )
        )
      } else if (grepl("snippet", query$part)) {
        list(
          kind = "youtube#videoListResponse",
          etag = "test-etag",
          pageInfo = list(
            totalResults = 1,
            resultsPerPage = 1
          ),
          items = list(
            list(
              kind = "youtube#video",
              etag = "video1-etag",
              id = "video1",
              snippet = list(
                # publishedAt is intentionally missing for this test
                channelId = "UCtest",
                title = "Test Video",
                description = "Test",
                channelTitle = "Test"
              )
            )
          )
        )
      }
    },
    
    {
      result <- get_all_channel_video_stats(channel_id = "UCtest")
      
      # Should handle missing publishedAt gracefully with NA
      expect_true(is.data.frame(result))
      expect_equal(nrow(result), 1)
      expect_true(is.na(result$publication_date[1]))
    }
  )
})