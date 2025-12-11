#' Helper Functions for Common YouTube Analysis Tasks
#'
#' High-level convenience functions that combine multiple API calls to provide
#' common YouTube analytics and research functionality out of the box.
#'
#' @name helper-functions
NULL

# Suppress R CMD check warnings for dplyr variables
utils::globalVariables(c("search_term", "view_count", "like_count", "total_views", 
                         "avg_engagement", "trending_score", "comment_count"))

#' Comprehensive channel analysis
#'
#' Performs a complete analysis of a YouTube channel including basic info,
#' statistics, recent videos, and performance metrics.
#'
#' @param channel_id Channel ID to analyze
#' @param max_videos Maximum number of recent videos to analyze (default: 50)
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param include_comments Whether to fetch comment statistics (requires more quota)
#' @param ... Additional arguments passed to API functions
#'
#' @return List containing comprehensive channel analysis
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic channel analysis
#' analysis <- analyze_channel("UCuAXFkgsw1L7xaCfnd5JJOw")
#' 
#' # Detailed analysis with comments
#' detailed <- analyze_channel("UCuAXFkgsw1L7xaCfnd5JJOw", 
#'                            max_videos = 100, 
#'                            include_comments = TRUE)
#' }
analyze_channel <- function(channel_id, 
                           max_videos = 50,
                           auth = "key",
                           include_comments = FALSE,
                           ...) {
  
  # Modern validation using checkmate
  assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
  assert_integerish(max_videos, len = 1, lower = 1, upper = 500, .var.name = "max_videos")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_logical(include_comments, len = 1, .var.name = "include_comments")
  
  message("Analyzing channel: ", channel_id)
  
  # Get basic channel information
  message("Fetching channel statistics...")
  channel_info <- get_channels_batch(
    channel_id, 
    part = "snippet,statistics,brandingSettings,contentDetails",
    auth = auth,
    show_progress = FALSE,
    ...
  )
  
  if (nrow(channel_info) == 0) {
    abort("Channel not found or inaccessible",
          channel_id = channel_id,
          class = "tuber_channel_not_found")
  }
  
  # Get upload playlist ID
  upload_playlist_id <- channel_info$contentDetails.relatedPlaylists.uploads[1]
  
  if (is.na(upload_playlist_id)) {
    warn("No uploads playlist found for channel. Analysis will be limited.",
         channel_id = channel_id,
         class = "tuber_no_uploads_playlist")
    videos_info <- data.frame()
  } else {
    # Get recent videos
    message("Fetching recent videos (", max_videos, ")...")
    playlist_items <- get_playlist_items(
      playlist_id = upload_playlist_id,
      max_results = max_videos,
      auth = auth,
      ...
    )
    
    if (length(playlist_items$items) > 0) {
      video_ids <- sapply(playlist_items$items, function(x) x$snippet$resourceId$videoId)
      
      # Get detailed video information
      message("Fetching video statistics...")
      videos_info <- get_videos_batch(
        video_ids,
        part = "snippet,statistics,contentDetails",
        auth = auth,
        show_progress = FALSE,
        ...
      )
      
      if (include_comments && nrow(videos_info) > 0) {
        message("Fetching comment counts...")
        videos_info$comment_threads <- sapply(video_ids, function(vid) {
          tryCatch({
            comments <- get_comment_threads(
              filter = c(video_id = vid),
              max_results = 1,
              auth = auth,
              ...
            )
            length(comments$items)
          }, error = function(e) NA_integer_)
        })
      }
    } else {
      videos_info <- data.frame()
    }
  }
  
  # Calculate performance metrics
  message("Calculating performance metrics...")
  performance_metrics <- list()
  
  if (nrow(videos_info) > 0) {
    # Convert statistics to numeric for calculations
    videos_info$view_count_num <- as.numeric(videos_info$viewCount %||% 0)
    videos_info$like_count_num <- as.numeric(videos_info$likeCount %||% 0)
    videos_info$comment_count_num <- as.numeric(videos_info$commentCount %||% 0)
    
    performance_metrics <- list(
      avg_views_per_video = mean(videos_info$view_count_num, na.rm = TRUE),
      median_views_per_video = median(videos_info$view_count_num, na.rm = TRUE),
      avg_likes_per_video = mean(videos_info$like_count_num, na.rm = TRUE),
      avg_comments_per_video = mean(videos_info$comment_count_num, na.rm = TRUE),
      total_recent_views = sum(videos_info$view_count_num, na.rm = TRUE),
      engagement_rate = mean(videos_info$like_count_num / pmax(videos_info$view_count_num, 1), na.rm = TRUE),
      videos_analyzed = nrow(videos_info),
      top_performing_video = if(nrow(videos_info) > 0) {
        videos_info[which.max(videos_info$view_count_num), c("title", "view_count_num")]
      } else NULL
    )
  }
  
  # Compile results
  analysis_result <- list(
    channel_info = channel_info,
    recent_videos = videos_info,
    performance_metrics = performance_metrics,
    analysis_timestamp = Sys.time(),
    parameters = list(
      max_videos = max_videos,
      include_comments = include_comments,
      auth_method = auth
    )
  )
  
  class(analysis_result) <- c("tuber_channel_analysis", "list")
  
  message("Channel analysis complete!")
  return(analysis_result)
}

#' Compare multiple channels
#'
#' Compares statistics and performance metrics across multiple YouTube channels.
#'
#' @param channel_ids Vector of channel IDs to compare
#' @param metrics Metrics to include in comparison
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param simplify Whether to return a simplified comparison table
#' @param ... Additional arguments passed to API functions
#'
#' @return List or data frame with channel comparison
#' @export
#'
#' @examples
#' \dontrun{
#' # Compare two channels
#' channels <- c("UCuAXFkgsw1L7xaCfnd5JJOw", "UCsXVk37bltHxD1rDPwtNM8Q")
#' comparison <- compare_channels(channels)
#' 
#' # Custom metrics comparison
#' comparison <- compare_channels(channels, 
#'                               metrics = c("subscriber_count", "video_count", "view_count"))
#' }
compare_channels <- function(channel_ids,
                            metrics = c("subscriber_count", "video_count", "view_count"),
                            auth = "key",
                            simplify = TRUE,
                            ...) {
  
  # Modern validation using checkmate
  assert_character(channel_ids, min.len = 2, .var.name = "channel_ids")
  assert_character(metrics, min.len = 1, .var.name = "metrics")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_flag(simplify, .var.name = "simplify")
  
  message("Comparing ", length(channel_ids), " channels...")
  
  # Get channel information
  channels_info <- get_channels_batch(
    channel_ids,
    part = "snippet,statistics,brandingSettings",
    auth = auth,
    show_progress = TRUE,
    ...
  )
  
  if (nrow(channels_info) == 0) {
    abort("No channel information could be retrieved",
          channel_ids = channel_ids,
          help = "Check that channel IDs are valid and accessible",
          class = "tuber_no_channel_data")
  }
  
  if (nrow(channels_info) < length(channel_ids)) {
    missing_count <- length(channel_ids) - nrow(channels_info)
    warn("Some channels could not be found or are inaccessible",
         missing_count = missing_count,
         total_requested = length(channel_ids),
         found = nrow(channels_info),
         class = "tuber_partial_channel_data")
  }
  
  # Calculate additional metrics
  comparison_data <- channels_info
  comparison_data$engagement_ratio <- comparison_data$view_count / pmax(comparison_data$subscriber_count, 1)
  comparison_data$videos_per_subscriber <- comparison_data$video_count / pmax(comparison_data$subscriber_count, 1)
  
  if (simplify) {
    # Create simplified comparison table
    comparison_table <- comparison_data[, c("title", metrics), drop = FALSE]
    
    # Add rankings
    for (metric in metrics) {
      if (metric %in% names(comparison_table)) {
        rank_col <- paste0(metric, "_rank")
        comparison_table[[rank_col]] <- rank(-as.numeric(comparison_table[[metric]]), na.last = "keep")
      }
    }
    
    # Sort by first metric
    if (length(metrics) > 0 && metrics[1] %in% names(comparison_table)) {
      comparison_table <- comparison_table[order(-as.numeric(comparison_table[[metrics[1]]])), ]
    }
    
    result <- list(
      comparison = comparison_table,
      summary = list(
        channels_compared = nrow(comparison_data),
        comparison_date = Sys.time(),
        metrics_used = metrics
      )
    )
  } else {
    result <- list(
      detailed_data = comparison_data,
      summary = list(
        channels_compared = nrow(comparison_data),
        comparison_date = Sys.time(),
        metrics_available = names(comparison_data)
      )
    )
  }
  
  class(result) <- c("tuber_channel_comparison", "list")
  
  message("Channel comparison complete!")
  return(result)
}

#' Trending analysis for search terms
#'
#' Analyzes trending videos and content for specific search terms or topics.
#'
#' @param search_terms Vector of search terms to analyze
#' @param max_results Maximum results per search term (default: 50)
#' @param time_period Time period for analysis: "week", "month", "year", "all"
#' @param order Sort order: "relevance", "date", "rating", "viewCount"
#' @param region_code Region code for localized trends
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to search functions
#'
#' @return List containing trending analysis results
#' @export
#'
#' @examples
#' \dontrun{
#' # Analyze trending topics
#' trends <- analyze_trends(c("machine learning", "AI", "data science"))
#' 
#' # Regional trending analysis
#' trends_us <- analyze_trends("music", region_code = "US", time_period = "week")
#' }
analyze_trends <- function(search_terms,
                          max_results = 50,
                          time_period = "month",
                          order = "viewCount",
                          region_code = NULL,
                          auth = "key",
                          ...) {
  
  # Modern validation using checkmate
  assert_character(search_terms, min.len = 1, .var.name = "search_terms")
  assert_choice(time_period, c("week", "month", "year", "all"), .var.name = "time_period")
  assert_choice(order, c("relevance", "date", "rating", "viewCount"), .var.name = "order")
  assert_integerish(max_results, len = 1, lower = 1, upper = 50, .var.name = "max_results")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  if (!is.null(region_code)) {
    assert_character(region_code, len = 1, pattern = "^[A-Z]{2}$", .var.name = "region_code")
  }
  
  message("Analyzing trends for ", length(search_terms), " search term(s)...")
  
  # Calculate date range
  published_after <- NULL
  if (time_period != "all") {
    days_back <- switch(time_period,
      "week" = 7,
      "month" = 30,
      "year" = 365
    )
    
    published_after <- format(Sys.Date() - days_back, "%Y-%m-%dT00:00:00Z")
  }
  
  # Search for each term
  all_results <- list()
  
  for (i in seq_along(search_terms)) {
    term <- search_terms[i]
    message("Searching for: '", term, "' (", i, "/", length(search_terms), ")")
    
    # Perform search
    search_results <- yt_search(
      term = term,
      max_results = max_results,
      order = order,
      published_after = published_after,
      region_code = region_code,
      auth = auth,
      ...
    )
    
    if (length(search_results$items) > 0) {
      # Get video details for statistics
      video_ids <- sapply(search_results$items, function(x) x$id$videoId)
      video_ids <- video_ids[!is.na(video_ids)]
      
      if (length(video_ids) > 0) {
        videos_details <- get_videos_batch(
          video_ids,
          part = "statistics,contentDetails",
          auth = auth,
          show_progress = FALSE,
          ...
        )
        
        # Combine search results with video details
        combined_results <- data.frame(
          search_term = term,
          video_id = video_ids,
          title = sapply(search_results$items, function(x) x$snippet$title %||% NA_character_),
          channel_title = sapply(search_results$items, function(x) x$snippet$channelTitle %||% NA_character_),
          published_at = sapply(search_results$items, function(x) x$snippet$publishedAt %||% NA_character_),
          view_count = as.numeric(videos_details$viewCount %||% 0),
          like_count = as.numeric(videos_details$likeCount %||% 0),
          comment_count = as.numeric(videos_details$commentCount %||% 0),
          stringsAsFactors = FALSE
        )
        
        all_results[[term]] <- combined_results
      }
    }
    
    # Add delay between searches to be respectful
    if (i < length(search_terms)) {
      Sys.sleep(0.2)
    }
  }
  
  # Combine all results
  if (length(all_results) > 0) {
    combined_data <- dplyr::bind_rows(all_results)
    
    # Calculate trend metrics
    trend_summary <- combined_data %>%
      dplyr::group_by(search_term) %>%
      dplyr::summarise(
        total_videos = dplyr::n(),
        avg_views = mean(view_count, na.rm = TRUE),
        total_views = sum(view_count, na.rm = TRUE),
        avg_engagement = mean(like_count / pmax(view_count, 1), na.rm = TRUE),
        top_video_views = max(view_count, na.rm = TRUE),
        trending_score = log10(total_views + 1) * avg_engagement * 100,
        .groups = "drop"
      ) %>%
      dplyr::arrange(dplyr::desc(trending_score))
    
    result <- list(
      detailed_results = combined_data,
      trend_summary = trend_summary,
      parameters = list(
        search_terms = search_terms,
        time_period = time_period,
        max_results = max_results,
        order = order,
        region_code = region_code,
        analysis_date = Sys.time()
      )
    )
  } else {
    result <- list(
      detailed_results = data.frame(),
      trend_summary = data.frame(),
      parameters = list(
        search_terms = search_terms,
        message = "No trending data found for the specified terms and criteria."
      )
    )
  }
  
  class(result) <- c("tuber_trend_analysis", "list")
  
  message("Trend analysis complete!")
  return(result)
}

#' Bulk video performance analysis
#'
#' Analyzes performance metrics for multiple videos in bulk.
#'
#' @param video_ids Vector of video IDs to analyze
#' @param include_comments Whether to include comment analysis
#' @param benchmark_percentiles Percentiles to use for performance benchmarking
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to API functions
#'
#' @return List containing bulk video analysis
#' @export
#'
#' @examples
#' \dontrun{
#' # Analyze multiple videos
#' video_ids <- c("dQw4w9WgXcQ", "M7FIvfx5J10", "kJQP7kiw5Fk")
#' analysis <- bulk_video_analysis(video_ids)
#' 
#' # Include comment analysis
#' detailed <- bulk_video_analysis(video_ids, include_comments = TRUE)
#' }
bulk_video_analysis <- function(video_ids,
                               include_comments = FALSE,
                               benchmark_percentiles = c(0.25, 0.5, 0.75, 0.9),
                               auth = "key",
                               ...) {
  
  # Modern validation using checkmate
  assert_character(video_ids, min.len = 1, .var.name = "video_ids")
  assert_flag(include_comments, .var.name = "include_comments")
  assert_numeric(benchmark_percentiles, lower = 0, upper = 1, .var.name = "benchmark_percentiles")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  message("Analyzing ", length(video_ids), " videos...")
  
  # Get video details
  videos_data <- get_videos_batch(
    video_ids,
    part = "snippet,statistics,contentDetails",
    auth = auth,
    show_progress = TRUE,
    ...
  )
  
  if (nrow(videos_data) == 0) {
    abort("No video data could be retrieved",
          video_ids = video_ids,
          help = "Check that video IDs are valid and accessible",
          class = "tuber_no_video_data")
  }
  
  # Convert to numeric for analysis
  videos_data$view_count_num <- as.numeric(videos_data$viewCount %||% 0)
  videos_data$like_count_num <- as.numeric(videos_data$likeCount %||% 0)
  videos_data$comment_count_num <- as.numeric(videos_data$commentCount %||% 0)
  
  # Calculate engagement metrics
  videos_data$engagement_rate <- videos_data$like_count_num / pmax(videos_data$view_count_num, 1)
  videos_data$comment_rate <- videos_data$comment_count_num / pmax(videos_data$view_count_num, 1)
  
  # Performance benchmarking
  benchmarks <- list(
    views = quantile(videos_data$view_count_num, benchmark_percentiles, na.rm = TRUE),
    likes = quantile(videos_data$like_count_num, benchmark_percentiles, na.rm = TRUE),
    comments = quantile(videos_data$comment_count_num, benchmark_percentiles, na.rm = TRUE),
    engagement_rate = quantile(videos_data$engagement_rate, benchmark_percentiles, na.rm = TRUE)
  )
  
  # Overall statistics
  summary_stats <- list(
    total_videos = nrow(videos_data),
    total_views = sum(videos_data$view_count_num, na.rm = TRUE),
    avg_views = mean(videos_data$view_count_num, na.rm = TRUE),
    median_views = median(videos_data$view_count_num, na.rm = TRUE),
    avg_engagement_rate = mean(videos_data$engagement_rate, na.rm = TRUE),
    top_performer = videos_data[which.max(videos_data$view_count_num), c("title", "view_count_num")],
    low_performer = videos_data[which.min(videos_data$view_count_num), c("title", "view_count_num")]
  )
  
  result <- list(
    video_data = videos_data,
    benchmarks = benchmarks,
    summary = summary_stats,
    analysis_date = Sys.time()
  )
  
  class(result) <- c("tuber_bulk_analysis", "list")
  
  message("Bulk video analysis complete!")
  return(result)
}

