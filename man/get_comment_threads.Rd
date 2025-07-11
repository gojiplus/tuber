% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_comment_threads.R
\name{get_comment_threads}
\alias{get_comment_threads}
\title{Get Comments Threads}
\usage{
get_comment_threads(
  filter = NULL,
  part = "snippet",
  text_format = "html",
  simplify = TRUE,
  max_results = 100,
  page_token = NULL,
  ...
)
}
\arguments{
\item{filter}{string; Required.
named vector of length 1
potential names of the entry in the vector:
\code{video_id}: video ID.
\code{channel_id}: channel ID.
\code{thread_id}: comma-separated list of comment thread IDs
\code{threads_related_to_channel}: channel ID.}

\item{part}{Comment resource requested. Required. Comma separated list
of one or more of the
following: \code{id, snippet}. e.g., \code{"id, snippet"},
\code{"id"}, etc. Default: \code{snippet}.}

\item{text_format}{Data Type: Character. Default is \code{"html"}.
Only takes \code{"html"} or \code{"plainText"}. Optional.}

\item{simplify}{Data Type: Boolean. Default is \code{TRUE}. If \code{TRUE},
the function returns a data frame. Else a list with all the
information returned.}

\item{max_results}{Maximum number of items that should be returned.
 Integer. Optional. Default is 100.
If the value is greater than 100 then the function fetches all the
results. The outcome is a simplified \code{data.frame}.}

\item{page_token}{Specific page in the result set that should be
returned. Optional.}

\item{\dots}{Additional arguments passed to \code{\link{tuber_GET}}.}
}
\value{
Nested named list. The entry \code{items} is a list of comments
along with meta information.
Within each of the \code{items} is an item \code{snippet} which
has an item \code{topLevelComment$snippet$textDisplay}
that contains the actual comment.

If simplify is \code{TRUE}, a \code{data.frame} with the following columns:
\code{authorDisplayName, authorProfileImageUrl, authorChannelUrl,
authorChannelId.value, videoId, textDisplay,
canRate, viewerRating, likeCount, publishedAt, updatedAt}
}
\description{
Get Comments Threads. Comment text fields are encoded to UTF-8 before sorting.
}
\examples{
\dontrun{

# Set API token via yt_oauth() first

get_comment_threads(filter = c(video_id = "N708P-A45D0"))
get_comment_threads(filter = c(video_id = "N708P-A45D0"), max_results = 101)
}
}
\references{
\url{https://developers.google.com/youtube/v3/docs/commentThreads/list}
}
