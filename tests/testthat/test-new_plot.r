# tests/testthat/test-new_plot.R

test_that("new_plot returns a ggplot object for basic usage", {
  p <- new_plot(mtcars, x = "cyl", y = "mpg", type = "point")
  expect_s3_class(p, "ggplot")
})


test_that("new_plot handles quoted inputs", {
  p <- new_plot(mtcars, x = "cyl", y = "mpg", type = "line")
  expect_s3_class(p, "ggplot")
})


test_that("new_plot errors when x or y columns do not exist", {
  expect_error(new_plot(mtcars, x = "missing", y = "mpg"), "not found")
  expect_error(new_plot(mtcars, x = "cyl", y = "missing"), "not found")
})


test_that("new_plot errors when grouping column does not exist", {
  expect_error(
    new_plot(mtcars, x = "cyl", y = "mpg", group = "not_a_col"),
    "Grouping column"
  )
})


test_that("numeric grouping auto-converts to factor", {
  # cyl is numeric in mtcars and should be converted internally
  p <- new_plot(mtcars, x = "cyl", y = "mpg", group = "cyl", type = "boxplot")
  expect_s3_class(p, "ggplot")

  # confirm discrete scales present
  scale_names <- vapply(p$scales$scales, function(s) s$aesthetics[1], character(1))
  expect_true(any(scale_names %in% c("colour", "fill")))
})


test_that("custom palettes work", {
  df <- mtcars
  df$cyl <- factor(df$cyl)

  p <- new_plot(df, "cyl", "mpg", group = "cyl", type = "point", palette = "orange")
  expect_s3_class(p, "ggplot")
})


test_that("invalid palette name falls back to viridis", {
  df <- mtcars
  df$cyl <- factor(df$cyl)

  p <- new_plot(df, "cyl", "mpg", group = "cyl", type = "point", palette = "NONEXISTENT")
  expect_s3_class(p, "ggplot")
})


test_that("viridis fallback matches expected viridis colors", {
  df <- mtcars
  df$cyl <- factor(df$cyl)

  p <- new_plot(df, "cyl", "mpg", group = "cyl", type = "point")

  plot_cols  <- unique(ggplot2::layer_data(p)$colour)
  expected   <- viridisLite::viridis(length(unique(df$cyl)))

  expect_equal(sort(plot_cols), sort(expected))
})


test_that("theme selection works", {
  p_minimal <- new_plot(mtcars, "cyl", "mpg", type = "point", theme_style = "minimal")
  p_classic <- new_plot(mtcars, "cyl", "mpg", type = "point", theme_style = "classic")

  expect_s3_class(p_minimal, "ggplot")
  expect_s3_class(p_classic,  "ggplot")
})


test_that("each geometry type renders without error", {
  expect_s3_class(new_plot(mtcars, "cyl", "mpg", type = "point"),   "ggplot")
  expect_s3_class(new_plot(mtcars, "cyl", "mpg", type = "line"),    "ggplot")
  expect_s3_class(new_plot(mtcars, "cyl", "mpg", type = "boxplot"), "ggplot")
  expect_s3_class(new_plot(mtcars, "cyl", "mpg", type = "violin"),  "ggplot")
})


test_that("violin fallback works when x is a factor", {
  df <- mtcars
  df$cyl <- factor(df$cyl)

  p <- new_plot(df, "cyl", "mpg", type = "violin")
  expect_s3_class(p, "ggplot")
})


test_that("default title is automatically generated", {
  p <- new_plot(mtcars, "cyl", "mpg", type = "point")
  expect_true("Plot of mpg by cyl" %in% p$labels$title)
})


test_that("user-specified title overrides default title", {
  p <- new_plot(mtcars, "cyl", "mpg", type = "point", title = "My Custom Title")
  expect_equal(p$labels$title, "My Custom Title")
})


test_that("pipe-friendly syntax works", {
  df <- mtcars |> dplyr::mutate(cyl = factor(cyl))
  p  <- df |> new_plot(x = "cyl", y = "mpg", type = "point")

  expect_s3_class(p, "ggplot")
})
