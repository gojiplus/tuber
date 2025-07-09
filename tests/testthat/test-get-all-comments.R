context("Get All Comments")

test_that("process_page handles comments with and without replies", {
  # Construct sample API response
  res <- list(
    items = list(
      list(
        id = "c1",
        snippet = list(topLevelComment = list(snippet = list(textDisplay = "t1"))),
        replies = list(comments = list(
          list(id = "c1r1", snippet = list(textDisplay = "r1")),
          list(id = "c1r2", snippet = list(textDisplay = "r2"))
        ))
      ),
      list(
        id = "c2",
        snippet = list(topLevelComment = list(snippet = list(textDisplay = "t2")))
        # No replies
      )
    )
  )

  df <- tuber:::process_page(res)

  expect_s3_class(df, "data.frame")
  expect_true(any(is.na(df$parentId)))    # top level comments
  expect_true(any(!is.na(df$parentId)))   # replies present
  expect_true("c2" %in% df$id)            # second comment present
  expect_false(any(df$parentId == "c2"))  # no replies for c2
})
