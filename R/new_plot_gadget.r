# NOTE: Do NOT use library(shiny) or library(miniUI)
# All shiny/miniUI functions must be prefixed (shiny::, miniUI::)

#' Interactive Shiny Gadget for Building new_plot() Graphics
#'
#' This gadget provides a graphical interface for constructing plots using
#' new_plot(). All variable selections are passed as quoted strings to ensure
#' consistency with the new_plot() function requirements.
#'
#' @param data A data frame to visualize.
#'
#' @returns A Shiny gadget interface that returns both the plot and the
#'   reproducible `new_plot()` code used to generate it.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   new_plot_gadget(mtcars)
#' }

new_plot_gadget <- function(data) {

  # ------------------------------------------------------------
  # Runtime dependency checks
  # ------------------------------------------------------------
  if (!requireNamespace("shiny", quietly = TRUE) ||
      !requireNamespace("miniUI", quietly = TRUE) ||
      !requireNamespace("glue", quietly = TRUE)) {
    stop("new_plot_gadget() requires the shiny, miniUI, and glue packages.")
  }

  data <- as.data.frame(data)

  # ------------------------------------------------------------
  # UI
  # ------------------------------------------------------------
  ui <- miniUI::miniPage(

    miniUI::gadgetTitleBar("new_plot() Gadget"),

    miniUI::miniContentPanel(

      shiny::fillRow(
        flex = c(1, 3),

        # --------------------------
        # Sidebar Inputs
        # --------------------------
        shiny::wellPanel(

          shiny::helpText("All variables selected below will be passed as quoted names."),

          shiny::selectInput("x", "X Variable (quoted):",
                             choices = names(data)),

          shiny::selectInput("y", "Y Variable (quoted):",
                             choices = names(data)),

          shiny::selectInput("group", "Group Variable (optional):",
                             choices = c("None", names(data)),
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

        # --------------------------
        # Plot Output
        # --------------------------
        shiny::plotOutput("plot", height = "100%")
      )
    )
  )

  # ------------------------------------------------------------
  # SERVER
  # ------------------------------------------------------------
  server <- function(input, output, session) {

    # Build plot
    reactive_plot <- shiny::reactive({

      group_arg <- if (input$group == "None") NULL else input$group
      palette_arg <- if (input$palette == "default") NULL else input$palette

      new_plot(
        data,
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

    output$plot <- shiny::renderPlot({
      reactive_plot()
    })

    # Return plot + generated code when 'Done' is clicked
    shiny::observeEvent(input$done, {

      group_code   <- if (input$group == "None") "" else glue::glue(', group = "{input$group}"')
      palette_code <- if (input$palette == "default") "" else glue::glue(', palette = "{input$palette}"')
      title_code   <- if (nzchar(input$title)) glue::glue(', title = "{input$title}"') else ""
      subt_code    <- if (nzchar(input$subtitle)) glue::glue(', subtitle = "{input$subtitle}"') else ""
      capt_code    <- if (nzchar(input$caption)) glue::glue(', caption = "{input$caption}"') else ""

      code <- glue::glue(
        'new_plot(data,
          x = "{input$x}",
          y = "{input$y}"{group_code},
          type = "{input$type}"{palette_code},
          theme_style = "{input$theme_style}"{title_code}{subt_code}{capt_code})'
      )

      shiny::stopApp(list(plot = reactive_plot(), code = code))
    })
  }

  # ------------------------------------------------------------
  # RUN THE GADGET
  # ------------------------------------------------------------
  shiny::runGadget(
    ui,
    server,
    viewer = shiny::dialogViewer("new_plot Gadget", width = 1000, height = 800)
  )
}
