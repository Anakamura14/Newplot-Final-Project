#' Create a streamlined, pipe-friendly ggplot with minimal code
#'
#' `new_plot()` is a wrapper around ggplot2 designed to simplify the
#' creation of high-quality, publication-ready graphics. The function uses
#' standard evaluation, meaning **all variable names must be provided as
#' quoted strings** (e.g., `"cyl"`, `"mpg"`). This ensures consistent behavior
#' across pipelines, scripts, packages, and R CMD check environments.
#'
#' The function automatically:
#' - validates inputs,
#' - selects a color palette (custom palettes or viridis fallback),
#' - detects grouping for color/fill scales,
#' - applies a consistent ggplot theme,
#' - generates an informative default title when none is provided.
#'
#' @import ggplot2
#' @import dplyr
#' @import rlang
#' @import glue
#' @importFrom viridisLite viridis
#' @importFrom grDevices colorRampPalette
#'
#' @param .data A data frame containing the variables to be plotted.
#' @param x A **quoted** column name specifying the x-axis variable (e.g., `"cyl"`).
#' @param y A **quoted** column name specifying the y-axis variable (e.g., `"mpg"`).
#' @param group Optional **quoted** column name used for color and fill grouping.
#'   Defaults to `NULL`.
#' @param type A character string indicating the geometry to draw.
#'   Must be one of `"point"`, `"line"`, `"boxplot"`, or `"violin"`.
#' @param palette Optional name of a built-in palette.
#'   Custom palettes include `"cyan"`, `"purple"`, `"red"`, `"blue"`,
#'   `"green"`, `"orange"`, `"pink"`, and `"yellow"`.
#'   If `NULL`, a viridis palette is used.
#' @param theme_style ggplot theme to apply. Must be `"minimal"` or `"classic"`.
#'   Defaults to `"minimal"`.
#' @param title Optional plot title. If omitted, a descriptive title is
#'   generated automatically.
#' @param subtitle Optional subtitle text.
#' @param caption Optional caption text.
#'
#' @return A `ggplot` object.
#'
#' @examples
#'
#' ## Basic point plot
#' new_plot(mtcars, x = "cyl", y = "mpg", type = "point")
#'
#' ## Iris dataset with grouping
#' iris |>
#'   new_plot(
#'     x = "Sepal.Length",
#'     y = "Petal.Length",
#'     group = "Species",
#'     type = "point",
#'     palette = "orange"
#'   )
#'
#' ## Pipe-friendly workflow with a grouping variable
#' mtcars |>
#'   dplyr::mutate(cyl = factor(cyl)) |>
#'   new_plot(
#'     x = "cyl",
#'     y = "mpg",
#'     group = "cyl",
#'     type = "boxplot",
#'     palette = "purple"
#'   )
#'
#'
#' @export
new_plot <- function(.data, x, y, group = NULL,
                     type = c("point","line","boxplot","violin"),
                     palette = NULL,
                     theme_style = c("minimal","classic"),
                     title = NULL,
                     subtitle = NULL,
                     caption = NULL) {

  # ---------------------------------------------
  # Receive piped data
  # ---------------------------------------------
  data <- .data

  # ---------------------------------------------
  # Validate data
  # ---------------------------------------------
  if (!inherits(data, "data.frame"))
    stop("data must be a data.frame")
  if ("grouped_df" %in% class(data))
    data <- ungroup(data)

  # ---------------------------------------------
  # Tidy-eval capture of variables
  # ---------------------------------------------

  # x
  if (is.character(x)) {
    x_sym <- rlang::sym(x)
  } else {
    x_sym <- rlang::ensym(x)
  }

  # y
  if (is.character(y)) {
    y_sym <- rlang::sym(y)
  } else {
    y_sym <- rlang::ensym(y)
  }

  # group (optional)
  if (!is.null(group)) {
    if (is.character(group)) {
      group_sym <- rlang::sym(group)
    } else {
      group_sym <- rlang::ensym(group)
    }
  } else {
    group_sym <- NULL
  }

  # Convert syms → strings
  x_col <- rlang::as_string(x_sym)
  y_col <- rlang::as_string(y_sym)
  group_col <- if (!is.null(group_sym)) rlang::as_string(group_sym) else NULL


  # ---------------------------------------------
  # Check column existence
  # ---------------------------------------------
  if (!x_col %in% names(data)) stop(glue("Column '{x_col}' not found in data."))
  if (!y_col %in% names(data)) stop(glue("Column '{y_col}' not found in data."))
  if (!is.null(group_col) && !group_col %in% names(data))
    stop(glue("Grouping column '{group_col}' not found in data."))

  # ---------------------------------------------
  # Determine number of groups
  # ---------------------------------------------
  # If grouping variable exists and is numeric, convert to factor
  if (!is.null(group_col)) {
    if (is.numeric(data[[group_col]])) {
      data[[group_col]] <- factor(data[[group_col]])
    }
  }

  # Determine number of groups
  if (!is.null(group_col)) {
    n_groups <- length(unique(data[[group_col]]))
  } else if (is.factor(data[[x_col]])) {
    n_groups <- length(unique(data[[x_col]]))
  } else {
    n_groups <- 1L
  }


  # ---------------------------------------------
  # Color palettes
  # ---------------------------------------------
  palette_list <- list(
    cyan   = c("#008B8B", "#00CDCD", "#00EEEE", "#00FFFF", "#20B2AA", "#48D1CC"),
    purple = c("#68228B", "#9932CC", "#B23AEE", "#BF3EFF", "#9B30FF", "#D8BFD8"),
    red    = c("#8B2323", "#CD3333", "#EE3B3B", "#FF4040", "#FF6347", "#FA8072"),
    blue   = c("#00008B", "#0000CD", "#4169E1", "#1E90FF", "#00BFFF", "#87CEFA"),
    green  = c("#006400", "#008000", "#228B22", "#32CD32", "#3CB371", "#66CDAA"),
    orange = c("#FF8C00", "#FFA500", "#FFB347", "#FF7F50", "#FF6347", "#FF4500"),
    pink   = c("#FF1493", "#FF69B4", "#FF82AB", "#FFB6C1", "#FFC0CB", "#FF69B4"),
    yellow = c("#FFD700", "#FFFF00", "#FFFACD", "#FAFAD2", "#FFEFD5", "#FFF8DC")
  )

  if (!is.null(palette) && palette %in% names(palette_list)) {
    pal <- palette_list[[palette]]
    palette_colors <- colorRampPalette(pal)(max(n_groups, length(pal)))
  } else {
    palette_colors <- viridisLite::viridis(n_groups)
  }

  # ---------------------------------------------
  # Themes
  # ---------------------------------------------
  theme_style <- match.arg(theme_style)
  theme_choice <- switch(theme_style,
                         minimal = theme_minimal(base_size = 14),
                         classic = theme_classic(base_size = 14))

  # ---------------------------------------------
  # Base aesthetics (modern tidy evaluation)
  # ---------------------------------------------
  if (is.null(group_sym)) {
    p <- ggplot(data, aes(!!x_sym, !!y_sym))
  } else {
    p <- ggplot(data, aes(!!x_sym, !!y_sym, color = !!group_sym, fill = !!group_sym))
  }

  # ---------------------------------------------
  # Normalize type arg
  # ---------------------------------------------
  type <- match.arg(type)

  # ---------------------------------------------
  # Geometry selection
  # ---------------------------------------------
  if (type == "point") {
    p <- p + geom_point(size = 3, alpha = 0.8)
    if (!is.null(group_col)) p <- p + scale_color_manual(values = palette_colors)

  } else if (type == "line") {
    p <- p + geom_line(linewidth = 1.2, alpha = 0.8)
    if (!is.null(group_col)) p <- p + scale_color_manual(values = palette_colors)

  } else if (type == "boxplot") {
    p <- p + geom_boxplot(alpha = 0.8, color = "black")
    if (!is.null(group_col)) p <- p + scale_fill_manual(values = palette_colors)
    else p <- p + scale_fill_manual(values = palette_colors[1])

  } else if (type == "violin") {

    if (!is.null(group_col)) {
      p <- p + geom_violin(alpha = 0.8, scale = "width", trim = FALSE, color = "black") +
        scale_fill_manual(values = palette_colors)

    } else if (is.factor(data[[x_col]])) {
      p <- p + geom_violin(aes(fill = !!x_sym), alpha = 0.8, scale = "width", trim = FALSE, color = "black") +
        scale_fill_manual(values = palette_colors)

    } else {
      p <- p + geom_violin(fill = palette_colors[1], alpha = 0.9, scale = "width", trim = FALSE, color = "black")
    }
  }

  # ---------------------------------------------
  # Labels + Theme
  # ---------------------------------------------
  title_text <- if (!is.null(title)) title else glue("Plot of {y_col} by {x_col}")

  p <- p + theme_choice +
    labs(
      title = title_text,
      subtitle = subtitle,
      caption = caption,
      x = x_col,
      y = y_col,
      color = group_col,
      fill = group_col
    )

  return(p)
}
