## ----include=FALSE------------------------------------------------------------
knitr::opts_chunk$set(
  eval = FALSE,
  message = FALSE,
  warning = FALSE,
  fig.width = 7,
  fig.height = 5
)

## -----------------------------------------------------------------------------
# devtools::install_github("Anakamura14/Newplot-Final-Project")
# library(newplot)

## -----------------------------------------------------------------------------
# new_plot(mtcars, x = "wt", y = "mpg", type = "point")

## -----------------------------------------------------------------------------
# mtcars |>
#   dplyr::mutate(cyl = factor(cyl)) |>
#   new_plot(x = "cyl", y = "mpg", group = "cyl", type = "violin")

## -----------------------------------------------------------------------------
# # Basic point plot
# new_plot(mtcars, x = "cyl", y = "mpg", type = "point")

## -----------------------------------------------------------------------------
# # Colored scatter plot
# new_plot(
#   iris,
#   x = "Sepal.Length",
#   y = "Petal.Length",
#   group = "Species",
#   type = "point",
#   palette = "orange"
# )

## -----------------------------------------------------------------------------
# # Grouped Boxplot
# new_plot(
#   mtcars |> dplyr::mutate(cyl = factor(cyl)),
#   x = "cyl",
#   y = "mpg",
#   group = "cyl",
#   type = "boxplot",
#   palette = "purple"
# )

## -----------------------------------------------------------------------------
# # Pipe-friendly workflow
# mtcars |>
#   dplyr::mutate(cyl = factor(cyl)) |>
#   new_plot(x = "cyl", y = "mpg", group = "cyl", type = "violin")

## -----------------------------------------------------------------------------
# library(newplot)
# 
# # Launch the interactive gadget using iris
# new_plot_gadget(iris)

## -----------------------------------------------------------------------------
# # Basic point test
# p1 <- new_plot(mtcars, x = "cyl", y = "mpg", type = "point")
# inherits(p1, "ggplot")

## -----------------------------------------------------------------------------
# # Test violin plot without grouping
# p2 <- new_plot(mtcars, x = "cyl", y = "mpg", type = "violin")
# inherits(p2, "ggplot")

## -----------------------------------------------------------------------------
# # Quoted
# p3 <- new_plot(mtcars, x = "cyl", y = "mpg", type = "line")
# inherits(p3, "ggplot")

## -----------------------------------------------------------------------------
# # Grouped boxplots
# mtcars2 <- mtcars |> dplyr::mutate(cyl = factor(cyl))
# 
# p5 <- new_plot(mtcars2, x = "cyl", y = "mpg", group = "cyl", type = "boxplot")
# inherits(p5, "ggplot")

## -----------------------------------------------------------------------------
# # Missing column
# tryCatch(
#   new_plot(mtcars, x = "missing", y = "mpg", type = "point"),
#   error = function(e) message("Passed: Missing column error caught")
# )

## -----------------------------------------------------------------------------
# # Custom palette
# p6 <- new_plot(
#   mtcars2,
#   x = "cyl",
#   y = "mpg",
#   group = "cyl",
#   type = "point",
#   palette = "orange"
# )
# inherits(p6, "ggplot")

## -----------------------------------------------------------------------------
# # Test dataset with grouping so colors are created
# mtcars2 <- mtcars |> dplyr::mutate(cyl = factor(cyl))
# 
# p_v <- new_plot(
#   mtcars2,
#   x = "cyl",
#   y = "mpg",
#   group = "cyl",
#   type = "point"
# )
# 
# # Extract actual colors used in the plot
# cols_used <- ggplot2::layer_data(p_v)$colour |> unique()
# 
# # Compare to viridis palette for 3 groups
# cols_expected <- viridisLite::viridis(3)
# 
# # Check if they match (order may differ, so we sort)
# identical(sort(cols_used), sort(cols_expected))

## -----------------------------------------------------------------------------
# new_plot(
#   iris,
#   x = "Sepal.Length",
#   y = "Petal.Length",
#   group = "Species",
#   type = "point",
#   palette = "orange",
#   title = "Petal vs. Sepal Length Across Iris Species"
# )

## -----------------------------------------------------------------------------
# new_plot(
#   mtcars |> dplyr::mutate(cyl = factor(cyl)),
#   x = "wt",
#   y = "mpg",
#   group = "cyl",
#   type = "point",
#   palette = "cyan",
#   title = "Fuel Efficiency Declines with Vehicle Weight"
# )

## -----------------------------------------------------------------------------
# set.seed(123)
# ph_data <- data.frame(
# age_group = factor(rep(c("18–39", "40–59", "60+"), each = 100)),
# systolic_bp = c(
# rnorm(100, mean = 118, sd = 10),
# rnorm(100, mean = 130, sd = 12),
# rnorm(100, mean = 142, sd = 15)
# )
# )
# 
# new_plot(
# ph_data,
# x = "age_group",
# y = "systolic_bp",
# type = "violin",
# palette = "red",
# title = "Systolic Blood Pressure Across Age Groups"
# )

