# NOTE: Do NOT use library(shiny) or library(miniUI)
# All shiny/miniUI functions must be called with shiny:: or miniUI::

#' Title
#'
#' @param data A data frame to visualize.
#'
#' @returns A shiny gadget interface.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Launch the interactive gadget
#'   new_plot_gadget(mtcars)
#' }

new_plot_gadget <- function(data) {

  # ------------------------------------------------------------
  # CRAN-required dependency checks
  # ------------------------------------------------------------
  if (!requireNamespace("shiny", quietly = TRUE) ||
      !requireNamespace("miniUI", quietly = TRUE) ||
      !requireNamespace("glue", quietly = TRUE)) {
    stop("The new_plot_gadget() requires the shiny, miniUI, and glue packages.")
  }

  # Ensure data is in data.frame format
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
        # SIDEBAR INPUTS
        # --------------------------
        shiny::wellPanel(
          shiny::selectInput("x", "X Variable:",
                             choices = names(data)),

          shiny::selectInput("y", "Y Variable:",
                             choices = names(data)),

          shiny::selectInput("group", "Group Variable (optional):",
                             choices = c("None", names(data)),
                             selected = "None"),

          shiny::selectInput("type", "Plot Type:",
                             choices = c("point", "line", "boxplot", "violin"),
                             selected = "point"),

          shiny::selectInput("palette", "Palette:",
                             choices = c("default", "cyan", "purple", "red", "blue",
                                         "green", "orange", "pink", "yellow"),
                             selected = "default"),

          shiny::selectInput("theme_style", "Theme:",
                             choices = c("minimal", "classic"),
                             selected = "minimal"),

          shiny::textInput("title", "Title:", ""),
          shiny::textInput("subtitle", "Subtitle:", ""),
          shiny::textInput("caption", "Caption:", "")
        ),

        # --------------------------
        # PLOT OUTPUT
        # --------------------------
        shiny::plotOutput("plot", height = "100%")
      )
    )
  )

  # ------------------------------------------------------------
  # SERVER
  # ------------------------------------------------------------
  server <- function(input, output, session) {

    # Build the plot reactively
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

    # Render the plot
    output$plot <- shiny::renderPlot({
      reactive_plot()
    })

    # When the user clicks DONE, return plot + code
    shiny::observeEvent(input$done, {

      group_code <- if (input$group == "None") "" else glue::glue(', group = "{input$group}"')
      palette_code <- if (input$palette == "default") "" else glue::glue(', palette = "{input$palette}"')

      code <- glue::glue(
        'new_plot(data,
          x = "{input$x}",
          y = "{input$y}"{group_code},
          type = "{input$type}"{palette_code},
          theme_style = "{input$theme_style}",
          title = "{input$title}",
          subtitle = "{input$subtitle}",
          caption = "{input$caption}")'
      )

      shiny::stopApp(list(
        plot = reactive_plot(),
        code = code
      ))
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
