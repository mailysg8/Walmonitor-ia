library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(ggridges)
library(ggplot2)

# Load data
walmart_data <- read.csv(
  "../data/walmart_sales_data.csv"
)

# UI
ui <- page_fillable(
    title = "Walmonitor",
    layout_sidebar(
        sidebar = sidebar(
          selectInput(
            inputId = "input_branch",
            label = "Branch",
            choices = c("All Branches / Cities" = "all",
                        "Branch A (Yangon)" = "A" ,
                        "Branch B (Mandalay)" = "B",
                        "Branch C (Naypyitaw)" = "C"),
            selected = c("all")
            ),
            radioButtons(
              inputId = "input_comparison",
              label = "Compare sales by",
              choices = c("Product line" = "Product line",
                          "Payment type" = "Payment",
                          "Gender" = "Gender",
                          "Customer type" = "Customer type"),
              selected = c("Product line")
            ),
          actionButton("action_button", "Reset filter"),
          open = "desktop"
        ),
      
    ),

    layout_columns(
        card(
            card_header("Output 1"),
            full_screen = TRUE
        ),
        card(
            card_header("Output 2"),
            full_screen = TRUE
        ),
        col_widths = c(6, 6)
    )
)

# Server
server <- function(input, output, session) {}

shinyApp(ui = ui, server = server)
