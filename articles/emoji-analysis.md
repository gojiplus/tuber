# Emoji Analysis in YouTube Comments

Emojis are increasingly important in social media communication. This
vignette demonstrates how to analyze emoji usage patterns in YouTube
comments using `tuber`’s built-in emoji functions.

## Setup

``` r
library(tuber)
library(dplyr)
library(ggplot2)
```

## Collecting Comments

``` r
yt_oauth("your_app_id", "your_app_secret")

comments <- get_all_comments(video_id = "your_video_id", max_results = 500)
```

## Basic Emoji Analysis

### Emoji Presence and Counts

``` r
comments <- comments |>
  mutate(
    has_emoji = has_emoji(textDisplay),
    emoji_count = count_emojis(textDisplay)
  )

summary(comments$emoji_count)

emoji_rate <- mean(comments$has_emoji, na.rm = TRUE) * 100
cat("Comments with emojis:", round(emoji_rate, 1), "%\n")
```

### Distribution of Emoji Usage

``` r
comments |>
  filter(emoji_count > 0) |>
  ggplot(aes(x = emoji_count)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Emojis per Comment",
    x = "Number of Emojis",
    y = "Number of Comments"
  ) +
  theme_minimal()
```

## Emoji Frequency Analysis

### Top Emojis

``` r
all_emojis <- unlist(extract_emojis(comments$textDisplay))

emoji_freq <- as.data.frame(table(all_emojis), stringsAsFactors = FALSE)
names(emoji_freq) <- c("emoji", "count")
emoji_freq <- emoji_freq[order(-emoji_freq$count), ]

head(emoji_freq, 15)

emoji_freq |>
  head(10) |>
  ggplot(aes(x = reorder(emoji, count), y = count)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Most Used Emojis",
    x = "Emoji",
    y = "Count"
  ) +
  theme_minimal()
```

## Temporal Analysis

### Emoji Usage Over Time

``` r
comments <- comments |>
  mutate(
    date = as.Date(publishedAt),
    emoji_count = count_emojis(textDisplay)
  )

daily_emoji <- comments |>
  group_by(date) |>
  summarise(
    total_comments = n(),
    comments_with_emoji = sum(has_emoji, na.rm = TRUE),
    total_emojis = sum(emoji_count, na.rm = TRUE),
    emoji_rate = comments_with_emoji / total_comments * 100,
    avg_emojis = total_emojis / total_comments
  )

ggplot(daily_emoji, aes(x = date, y = emoji_rate)) +
  geom_line(color = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.2) +
  labs(
    title = "Emoji Usage Rate Over Time",
    x = "Date",
    y = "% of Comments with Emojis"
  ) +
  theme_minimal()
```

## Sentiment Categories

Emojis can indicate sentiment. Here’s a simple categorization approach:

``` r
positive_emojis <- c(
  "\U0001F600", "\U0001F601", "\U0001F602", "\U0001F603", "\U0001F604",
  "\U0001F605", "\U0001F606", "\U0001F60A", "\U0001F60D", "\U0001F618",
  "\U0001F44D", "\U0001F44F", "\U00002764", "\U0001F389", "\U0001F38A"
)

negative_emojis <- c(
  "\U0001F620", "\U0001F621", "\U0001F622", "\U0001F623", "\U0001F624",
  "\U0001F625", "\U0001F62D", "\U0001F44E", "\U0001F4A9", "\U0001F61E"
)

comments <- comments |>
  mutate(
    emojis = extract_emojis(textDisplay),
    pos_emoji = sapply(emojis, function(e) sum(e %in% positive_emojis)),
    neg_emoji = sapply(emojis, function(e) sum(e %in% negative_emojis)),
    emoji_sentiment = case_when(
      pos_emoji > neg_emoji ~ "positive",
      neg_emoji > pos_emoji ~ "negative",
      pos_emoji == 0 & neg_emoji == 0 ~ "none",
      TRUE ~ "neutral"
    )
  )

table(comments$emoji_sentiment)
```

## Engagement Correlation

### Do emoji comments get more likes?

``` r
engagement_summary <- comments |>
  group_by(has_emoji) |>
  summarise(
    n = n(),
    mean_likes = mean(likeCount, na.rm = TRUE),
    median_likes = median(likeCount, na.rm = TRUE)
  )

print(engagement_summary)

ggplot(comments, aes(x = has_emoji, y = likeCount + 1)) +
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  scale_y_log10() +
  labs(
    title = "Like Counts: Emoji vs Non-Emoji Comments",
    x = "Contains Emoji",
    y = "Likes (log scale)"
  ) +
  theme_minimal()
```

## Cross-Video Comparison

### Compare emoji usage across videos

``` r
video_ids <- c("video_id_1", "video_id_2", "video_id_3")

all_comments <- lapply(video_ids, function(vid) {
  comments <- get_all_comments(video_id = vid, max_results = 200)
  comments$video_id <- vid
  comments
})
all_comments <- bind_rows(all_comments)

video_emoji_stats <- all_comments |>
  mutate(emoji_count = count_emojis(textDisplay)) |>
  group_by(video_id) |>
  summarise(
    total_comments = n(),
    emoji_rate = mean(emoji_count > 0) * 100,
    avg_emojis = mean(emoji_count)
  )

print(video_emoji_stats)
```

## Working with Clean Text

For text analysis that should exclude emojis:

``` r
comments <- comments |>
  mutate(
    clean_text = remove_emojis(textDisplay),
    clean_text = trimws(gsub("\\s+", " ", clean_text))
  )

head(comments$clean_text[comments$has_emoji], 3)
```

## Performance Tips

For large datasets:

``` r
comments_sample <- comments[sample(nrow(comments), min(1000, nrow(comments))), ]

comments_sample <- comments_sample |>
  mutate(emoji_count = count_emojis(textDisplay))

emoji_rate_estimate <- mean(comments_sample$emoji_count > 0) * 100
```

## Summary

Key functions used in this analysis:

| Function                                                                           | Purpose                         |
|------------------------------------------------------------------------------------|---------------------------------|
| [`has_emoji()`](https://gojiplus.github.io/tuber/reference/has_emoji.md)           | Check if text contains emojis   |
| [`count_emojis()`](https://gojiplus.github.io/tuber/reference/count_emojis.md)     | Count emojis in text            |
| [`extract_emojis()`](https://gojiplus.github.io/tuber/reference/extract_emojis.md) | Get list of emojis from text    |
| [`remove_emojis()`](https://gojiplus.github.io/tuber/reference/remove_emojis.md)   | Strip emojis from text          |
| [`replace_emojis()`](https://gojiplus.github.io/tuber/reference/replace_emojis.md) | Replace emojis with custom text |

These functions work directly on character vectors, making them easy to
use with
[`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
and other tidyverse workflows.
