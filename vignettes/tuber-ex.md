---
title: "Using tuber"
author: "Gaurav Sood"
date: "2016-10-02"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Using tuber}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

## tuber: Access YouTube via R


### Install, Load the package

To install the latest version from CRAN: 


```r
install.packages("tuber")
```

The latest development version of the package will always be on GitHub. Instructions for installing the package from Github are provided below.


```r
# install.packages('devtools')
devtools::install_github("soodoku/tuber", build_vignettes = TRUE)
```

Next, load the package: 


```r
library(tuber)
```

### Using the package

To get going, get the application id and password from Google Developer Console (see [https://developers.google.com/youtube/v3/getting-started](https://developers.google.com/youtube/v3/getting-started)). Enable YouTube APIs. Then set the application id and password via the `yt_oauth` function. For more information about YouTube OAuth, see [YouTube OAuth Guide](https://developers.google.com/youtube/v3/guides/authentication).



```r
yt_oauth("998136489867-5t3tq1g7hbovoj46dreqd6k5kd35ctjn.apps.googleusercontent.com", "MbOSt6cQhhFkwETXKur-L9rN")
```


```r
## Waiting for authentication in browser...
## Press Esc/Ctrl + C to abort
## Authentication complete.
```

#### Get Statistics of a Video



```r
get_stats(video_id="N708P-A45D0")
```


```
## No. of Views 525112 
## No. of Likes 5576 
## No. of Dislikes 3564 
## No. of Favorites 0 
## No. of Comments 5329
```

#### Get Information About a Video



```r
get_details(video_id="N708P-A45D0")
```

#### Get Caption of a Video



```r
get_captions(video_id="yJXTXN4xrI8")
```

```
## <?xml version="1.0" encoding="utf-8"?>
## <transcript>
##   <text start="6.614" dur="1.549">Every four seconds,</text>
##   <text start="8.163" dur="1.534">someone is diagnosed with</text>
##   <text start="9.697" dur="1.885">Alzheimer&amp;#39;s disease.</text>
##   <text start="11.582" dur="2.172">It&amp;#39;s the most common cause of dementia,</text>
##   <text start="13.754" dur="2.859">affecting over 40 million people worldwide,</text>
##   <text start="16.613" dur="2.52">and yet finding a cure is something that still</text>
##   <text start="19.133" dur="2.482">eludes researchers today.</text>
##   <text start="21.615" dur="3.273">Dr. Alois Alzheimer, a German psychiatrist,</text>
##   <text start="24.888" dur="3.047">first described the symptoms in 1901</text>
##   <text start="27.935" dur="2.46">when he noticed that a particular hospital patient</text>
##   <text start="30.395" dur="1.917">had some peculiar problems,</text>
##   <text start="32.312" dur="1.803">including difficulty sleeping,</text>
##   <text start="34.115" dur="3.37">disturbed memory, drastic mood changes,</text>
##   <text start="37.485" dur="2.166">and increasing confusion.</text>
##   <text start="39.651" dur="1.877">When the patient passed away,</text>
##   <text start="41.528" dur="2.211">Alzheimer was able to do an autopsy</text>
##   <text start="43.739" dur="2.04">and test his idea that perhaps</text>
##   <text start="45.779" dur="2.421">her symptoms were caused by irregularities</text>
##   <text start="48.2" dur="1.963">in the brain&amp;#39;s structure.</text>
##   <text start="50.163" dur="1.951">What he found beneath the microscope</text>
##   <text start="52.114" dur="2.473">were visible differences in brain tissue</text>
##   <text start="54.587" dur="2.194">in the form of misfolded proteins</text>
##   <text start="56.781" dur="1.334">called plaques,</text>
##   <text start="58.115" dur="2.433">and neurofibrillary tangles.</text>
##   <text start="60.548" dur="2.378">Those plaques and tangles work together</text>
##   <text start="62.926" dur="2.419">to break down the brain&amp;#39;s structure.</text>
##   <text start="65.345" dur="1.792">Plaques arise when another protein</text>
##   <text start="67.137" dur="2.643">in the fatty membrane surrounding nerve cells</text>
##   <text start="69.78" dur="2.697">gets sliced up by a particular enzyme,</text>
##   <text start="72.477" dur="2.585">resulting in beta-amyloid proteins,</text>
##   <text start="75.062" dur="1.799">which are sticky and have a tendency</text>
##   <text start="76.861" dur="1.587">to clump together.</text>
##   <text start="78.448" dur="1.952">That clumping is what forms the things</text>
##   <text start="80.4" dur="2.131">we know as plaques.</text>
##   <text start="82.531" dur="1.793">These clumps block signaling</text>
##   <text start="84.324" dur="1.502">and, therefore, communication</text>
##   <text start="85.826" dur="2.336">between cells, and also seem to trigger</text>
##   <text start="88.162" dur="2.536">immune reactions that cause the destruction</text>
##   <text start="90.698" dur="2.134">of disabled nerve cells.</text>
##   <text start="92.832" dur="2.782">In Alzheimer&amp;#39;s disease, neurofibrillary tangles</text>
##   <text start="95.614" dur="3.085">are built from a protein known as tau.</text>
##   <text start="98.699" dur="2.89">The brain&amp;#39;s nerve cells contain a network of tubes</text>
##   <text start="101.589" dur="2.024">that act like a highway for food molecules</text>
##   <text start="103.613" dur="1.563">among other things.</text>
##   <text start="105.176" dur="2.543">Usually, the tau protein ensures that these tubes</text>
##   <text start="107.719" dur="2.256">are straight, allowing molecules</text>
##   <text start="109.975" dur="1.917">to pass through freely.</text>
##   <text start="111.892" dur="1.709">But in Alzheimer&amp;#39;s disease,</text>
##   <text start="113.601" dur="3.463">the protein collapses into twisted strands or tangles,</text>
##   <text start="117.064" dur="1.832">making the tubes disintegrate,</text>
##   <text start="118.896" dur="2.505">obstructing nutrients from reaching the nerve cell</text>
##   <text start="121.401" dur="2.628">and leading to cell death.</text>
##   <text start="124.029" dur="2.336">The destructive pairing of plaques and tangles</text>
##   <text start="126.365" dur="2.332">starts in a region called the hippocampus,</text>
##   <text start="128.697" dur="2.419">which is responsible for forming memories.</text>
##   <text start="131.116" dur="1.713">That&amp;#39;s why short-term memory loss</text>
##   <text start="132.829" dur="2.702">is usually the first symptom of Alzheimer&amp;#39;s.</text>
##   <text start="135.531" dur="1.884">The proteins then progressively invade</text>
##   <text start="137.415" dur="1.616">other parts of the brain,</text>
##   <text start="139.031" dur="1.834">creating unique changes that signal</text>
##   <text start="140.865" dur="2.416">various stages of the disease.</text>
##   <text start="143.281" dur="1.235">At the front of the brain,</text>
##   <text start="144.516" dur="3.536">the proteins destroy the ability to process logical thoughts.</text>
##   <text start="148.052" dur="3.168">Next, they shift to the region that controls emotions,</text>
##   <text start="151.22" dur="2.337">resulting in erratic mood changes.</text>
##   <text start="153.557" dur="1.224">At the top of the brain,</text>
##   <text start="154.781" dur="2.364">they cause paranoia and hallucinations,</text>
##   <text start="157.145" dur="2.053">and once they reach the brain&amp;#39;s rear,</text>
##   <text start="159.198" dur="1.999">the plaques and tangles work together</text>
##   <text start="161.197" dur="2.418">to erase the mind&amp;#39;s deepest memories.</text>
##   <text start="163.615" dur="1.621">Eventually the control centers governing</text>
##   <text start="165.236" dur="2.794">heart rate and breathing are overpowered as well</text>
##   <text start="168.03" dur="1.796">resulting in death.</text>
##   <text start="169.826" dur="2.039">The immensely destructive nature of this disease</text>
##   <text start="171.865" dur="2.999">has inspired many researchers to look for a cure</text>
##   <text start="174.864" dur="3.752">but currently they&amp;#39;re focused on slowing its progression.</text>
##   <text start="178.616" dur="1.387">One temporary treatment</text>
##   <text start="180.003" dur="2.627">helps reduce the break down of acetylcholine,</text>
##   <text start="182.63" dur="2.653">an important chemical messenger in the brain</text>
##   <text start="185.283" dur="2.519">which is decreased in Alzheimer&amp;#39;s patients</text>
##   <text start="187.802" dur="3.063">due to the death of the nerve cells that make it.</text>
##   <text start="190.865" dur="2.316">Another possible solution is a vaccine</text>
##   <text start="193.181" dur="2.461">that trains the body&amp;#39;s immune system to attack</text>
##   <text start="195.642" dur="3.587">beta-amyloid plaques before they can form clumps.</text>
##   <text start="199.229" dur="2.801">But we still need to find an actual cure.</text>
##   <text start="202.03" dur="1.75">Alzheimer&amp;#39;s disease was discovered</text>
##   <text start="203.78" dur="1.669">more than a century ago,</text>
##   <text start="205.449" dur="2.664">and yet still it is not well understood.</text>
##   <text start="208.113" dur="1.667">Perhaps one day we&amp;#39;ll grasp</text>
##   <text start="209.78" dur="2.916">the exact mechanisms at work behind this threat</text>
##   <text start="212.696" dur="2.214">and a solution will be unearthed.</text>
## </transcript>
## 
```

#### Search Videos


```r
yt_search("Barack Obama")
```

```
## Total Results 1000000
```

#### Get Comments on a video


```r
res <- get_comments(video_id="N708P-A45D0")
# First comment
res$items[[1]]$snippet$topLevelComment$snippet$textDisplay
```

```
## Hillary Clinton is a corporate puppet, a flip-flopper, and a robotic establishment politician. She also constantly plays the card of vote for me because I have a vagina. She has received lots of money from wall street and corporations that own her. She was against  gay marriage, for the Iraq war, for the Patriot Act, undecided on the Keystone Pipeline for a long time(that should be a no brainier if you are truly an environmentalist), and is currently against Glass-Steagall. She is a mediocre liberal that tries to put on a progressive mask through vague messages. She is a phony crook that as Sanders said, talks the talk but doesn&#39;t walk the walk. She is the embodiment of politics as usual were money controls government. From her you should only expect at most a speck of progressivism. <br /><br />That is why you shouldn&#39;t vote for Clinton.﻿
```

### Get statistics of all the videos in a channel


```r
a <- list_channel_resources(id = "UCT5Cx1l4IS3wHkJXNyuj4TA", part="contentDetails")

# Uploaded playlists:
playlist_id <- a$items[[1]]$contentDetails$relatedPlaylists$uploads

# Get videos on the playlist
vids <- get_playlist_items(playlist_id) 

# Video ids
vid_ids <- as.vector(unlist(sapply(vids$items, "[", "contentDetails")))

# get stats:
res <- data.frame()
for (i in vid_ids) {

	temp <- get_stats(i)
	temp$vid_id <- i
	res  <- rbind(res, temp)
}
```

```
## No. of Views 707 
## No. of Likes 3 
## No. of Dislikes 1 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 689 
## No. of Likes 0 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 456 
## No. of Likes 1 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 381 
## No. of Likes 0 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 174971 
## No. of Likes 5 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 563 
## No. of Likes 3 
## No. of Dislikes 2 
## No. of Favorites 0 
## No. of Comments 3 
## No. of Views 242816 
## No. of Likes 12 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 4 
## No. of Views 994 
## No. of Likes 0 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 291 
## No. of Likes 1 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 1 
## No. of Views 95661 
## No. of Likes 3 
## No. of Dislikes 1 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 10889 
## No. of Likes 17 
## No. of Dislikes 9 
## No. of Favorites 0 
## No. of Comments 1 
## No. of Views 76 
## No. of Likes 0 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 672 
## No. of Likes 0 
## No. of Dislikes 0 
## No. of Favorites 0 
## No. of Comments 0 
## No. of Views 3540 
## No. of Likes 14 
## No. of Dislikes 2 
## No. of Favorites 0 
## No. of Comments 5
```

```r
res
```

```
##    viewCount likeCount dislikeCount favoriteCount commentCount      vid_id
## 1        707         3            1             0            0 91gZ4taDiDE
## 2        689         0            0             0            0 bHPCvSqTxn4
## 3        456         1            0             0            0 h2UPH87kjhc
## 4        381         0            0             0            0 E2VtxjljZCE
## 5     174971         5            0             0            0 5Ajfk620fA0
## 6        563         3            2             0            3 PdI3HjulcA4
## 7     242816        12            0             0            4 IGUZAeLoGOU
## 8        994         0            0             0            0 0L1HCWo7Py0
## 9        291         1            0             0            1 IM6bGZ-Msf0
## 10     95661         3            1             0            0 hfUnu9QQii4
## 11     10889        17            9             0            1 aPyWkycj8TE
## 12        76         0            0             0            0 g_q_MwpQTb0
## 13       672         0            0             0            0 rryhpc7krCw
## 14      3540        14            2             0            5 dRK64OVdfmo
```
