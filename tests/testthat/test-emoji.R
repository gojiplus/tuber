test_that("has_emoji detects emojis correctly", {
  expect_true(has_emoji("Hello \U0001F44B"))
  expect_true(has_emoji("\U0001F600"))
  expect_true(has_emoji("Text with \U0001F30D earth"))

  expect_false(has_emoji("Hello world"))
  expect_false(has_emoji("No emojis here!"))
  expect_false(has_emoji(""))

  result <- has_emoji(c("No emoji", "Has \U0001F600", "Also none"))
  expect_equal(result, c(FALSE, TRUE, FALSE))
})

test_that("has_emoji handles edge cases", {
  expect_equal(has_emoji(NULL), logical(0))
  expect_equal(has_emoji(character(0)), logical(0))

  result <- has_emoji(c("test", NA, "\U0001F600"))
  expect_equal(result[1], FALSE)
  expect_equal(result[3], TRUE)
})

test_that("extract_emojis extracts emojis correctly", {
  result <- extract_emojis("Hello \U0001F44B World \U0001F30D!")
  expect_equal(length(result), 1)
  expect_equal(result[[1]], c("\U0001F44B", "\U0001F30D"))

  result <- extract_emojis("No emojis")
  expect_equal(result[[1]], character(0))

  result <- extract_emojis(c("No emoji", "\U0001F600\U0001F601"))
  expect_equal(length(result), 2)
  expect_equal(result[[1]], character(0))
  expect_equal(result[[2]], c("\U0001F600", "\U0001F601"))
})

test_that("extract_emojis handles edge cases", {
  expect_equal(extract_emojis(NULL), list())
  expect_equal(extract_emojis(character(0)), list())

  result <- extract_emojis(c("test", NA))
  expect_equal(result[[1]], character(0))
  expect_equal(result[[2]], character(0))
})

test_that("count_emojis counts correctly", {
  expect_equal(count_emojis("Hello world"), 0L)
  expect_equal(count_emojis("Hello \U0001F44B"), 1L)
  expect_equal(count_emojis("\U0001F600\U0001F601\U0001F602"), 3L)

  result <- count_emojis(c("No emoji", "\U0001F600", "\U0001F600\U0001F601"))
  expect_equal(result, c(0L, 1L, 2L))
})

test_that("count_emojis handles edge cases", {
  expect_equal(count_emojis(NULL), integer(0))
  expect_equal(count_emojis(character(0)), integer(0))
  expect_equal(count_emojis(NA_character_), 0L)
})

test_that("remove_emojis removes emojis correctly", {
  expect_equal(remove_emojis("Hello \U0001F44B World!"), "Hello  World!")
  expect_equal(remove_emojis("No emojis"), "No emojis")
  expect_equal(remove_emojis("\U0001F600\U0001F601\U0001F602"), "")

  result <- remove_emojis(c("No emoji", "Has \U0001F600 emoji"))
  expect_equal(result, c("No emoji", "Has  emoji"))
})

test_that("remove_emojis handles edge cases", {
  expect_equal(remove_emojis(NULL), character(0))
  expect_equal(remove_emojis(character(0)), character(0))
})

test_that("replace_emojis replaces emojis correctly", {
  expect_equal(
    replace_emojis("Hello \U0001F44B World!", replacement = "[emoji]"),
    "Hello [emoji] World!"
  )
  expect_equal(
    replace_emojis("\U0001F600\U0001F601", replacement = "*"),
    "**"
  )
  expect_equal(
    replace_emojis("No emojis", replacement = "[emoji]"),
    "No emojis"
  )
})

test_that("replace_emojis handles edge cases", {
  expect_equal(replace_emojis(NULL), character(0))
  expect_equal(replace_emojis(character(0)), character(0))
})

test_that("emoji functions work with various emoji types", {
  emoticons <- "\U0001F600\U0001F601\U0001F602"
  expect_true(has_emoji(emoticons))
  expect_equal(count_emojis(emoticons), 3L)

  transport <- "\U0001F680\U0001F697"
  expect_true(has_emoji(transport))
  expect_equal(count_emojis(transport), 2L)

  misc_symbols <- "\U00002600\U00002601"
  expect_true(has_emoji(misc_symbols))
  expect_equal(count_emojis(misc_symbols), 2L)

  supplemental <- "\U0001F90D\U0001F90E"
  expect_true(has_emoji(supplemental))
  expect_equal(count_emojis(supplemental), 2L)
})

test_that("emoji functions handle mixed content", {
  mixed <- "Great video! \U0001F44D Check this out: example.com \U0001F680 #awesome"
  expect_true(has_emoji(mixed))
  expect_equal(count_emojis(mixed), 2L)
  expect_equal(
    extract_emojis(mixed)[[1]],
    c("\U0001F44D", "\U0001F680")
  )
  expect_equal(
    remove_emojis(mixed),
    "Great video!  Check this out: example.com  #awesome"
  )
})
