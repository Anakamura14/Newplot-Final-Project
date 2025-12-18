#' Interactive Shiny Gadget for Constructing new_plot() Figures
#'
#' This gadget provides a visual interface for building plots using \code{new_plot()}.
#' All variables chosen in the UI are automatically passed as quoted column names,
#' ensuring compatibility with the function’s requirements. Users can select
#' aesthetics, plot types, themes, palettes, and labels, preview the resulting plot,
#' and export reproducible new_plot() code.
#'
#' @import shiny
#' @import miniUI
#' @import glue
#'
#' @param data A data frame to visualize.
#'
#' @return A Shiny gadget that returns both the rendered ggplot object and the exact
#'   \code{new_plot()} code needed to recreate it.
#'
#' @export
#'
#' @details
#' This function launches an interactive Shiny gadget and is intended for
#' interactive use. Because the gadget requires user interaction, no
#' runnable examples are included. See the vignette for usage demonstrations.

new_plot_gadget <- function(data) {

  # ---------------------------------------------------------------------------
  # Runtime dependency check (CRAN-friendly)
  # ---------------------------------------------------------------------------
  if (!requireNamespace("shiny", quietly = TRUE) ||
      !requireNamespace("miniUI", quietly = TRUE) ||
      !requireNamespace("glue", quietly = TRUE)) {
    stop("new_plot_gadget() requires the shiny, miniUI, and glue packages.")
  }

  # Convert input to data frame
  data <- as.data.frame(data)

  # Column choices for user selection
  col_names <- names(data)

  # ---------------------------------------------------------------------------
  # UI
  # ---------------------------------------------------------------------------
  ui <- miniUI::miniPage(

    miniUI::gadgetTitleBar("new_plot() Gadget"),

    miniUI::miniContentPanel(

      shiny::fillRow(
        flex = c(1, 3),

        # ----------------------------------------------------
        # Sidebar
        # ----------------------------------------------------
        shiny::wellPanel(

          shiny::helpText("All variables will be passed as quoted column names."),

          shiny::selectInput("x", "X Variable:",
                             choices = col_names),

          shiny::selectInput("y", "Y Variable:",
                             choices = col_names),

          shiny::selectInput("group", "Group (optional):",
                             choices = c("None", col_names),
                             selected = "None"),

          shiny::selectInput("type", "Plot Type:",
                             choices = c("point", "line", "boxplot", "violin"),
                             selected = "point"),

          shiny::selectInput("palette", "Palette:",
                             choices = c("default", "cyan", "purple", "red",
                                         "blue", "green", "orange", "pink",
                                         "yellow"),
                             selected = "default"),

          shiny::selectInput("theme_style", "Theme:",
                             choices = c("minimal", "classic"),
                             selected = "minimal"),

          shiny::textInput("title", "Title:", ""),
          shiny::textInput("subtitle", "Subtitle:", ""),
          shiny::textInput("caption", "Caption:", "")
        ),

        # ----------------------------------------------------
        # Plot preview output
        # ----------------------------------------------------
        shiny::plotOutput("plot", height = "100%")
      )
    )
  )

  # ---------------------------------------------------------------------------
  # Server logic
  # ---------------------------------------------------------------------------
  server <- function(input, output, session) {

    # Reactive plot builder
    reactive_plot <- shiny::reactive({

      # ---------------------------
      # Prepare grouping variable
      # ---------------------------
      group_arg <- if (input$group == "None") NULL else input$group
      palette_arg <- if (input$palette == "default") NULL else input$palette

      # Convert numeric grouping variable → factor (matches new_plot logic)
      data_mod <- data
      if (!is.null(group_arg) && is.numeric(data_mod[[group_arg]])) {
        data_mod[[group_arg]] <- factor(data_mod[[group_arg]])
      }

      # Generate plot object
      new_plot(
        data_mod,
        x = input$x,
        y = input$y,
        group = group_arg,
        type = input$type,
        palette = palette_arg,
        theme_style = input$theme_style,
        title = input$title,
        subtitle = input$subtitle,
        caption = input$caption
      )
    })

    # Render preview
    output$plot <- shiny::renderPlot({
      reactive_plot()
    })

    # When user clicks DONE: return ggplot + code
    shiny::observeEvent(input$done, {

      # Build code components
      group_code   <- if (input$group == "None") "" else glue::glue(', group = "{input$group}"')
      palette_code <- if (input$palette == "default") "" else glue::glue(', palette = "{input$palette}"')
      title_code   <- if (nzchar(input$title)) glue::glue(', title = "{input$title}"') else ""
      subt_code    <- if (nzchar(input$subtitle)) glue::glue(', subtitle = "{input$subtitle}"') else ""
      capt_code    <- if (nzchar(input$caption)) glue::glue(', caption = "{input$caption}"') else ""

      # Assemble reproducible code
      code <- glue::glue(
        'new_plot(data,
          x = "{input$x}",
          y = "{input$y}"{group_code},
          type = "{input$type}"{palette_code},
          theme_style = "{input$theme_style}"{title_code}{subt_code}{capt_code})'
      )

      # Return output
      shiny::stopApp(list(
        plot = reactive_plot(),
        code = code
      ))
    })
  }

  # ---------------------------------------------------------------------------
  # Launch gadget
  # ---------------------------------------------------------------------------
  shiny::runGadget(
    ui,
    server,
    viewer = shiny::dialogViewer("new_plot Gadget", width = 1000, height = 800)
  )
}
