library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(ggridges)
library(ggplot2)
library(stringr)

# Load data
walmart_data <- read.csv(
  "../data/walmart_sales_data.csv"
) |> rename(
  invoice_id=Invoice.ID,
  branch=Branch,
  city=City,
  customer_type=Customer.type,
  gender=Gender,
  product_line=Product.line,
  total=Total,
  date=Date,
  payment=Payment
  ) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d")) 

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
              choices = c("Product line" = "product_line",
                          "Payment type" = "payment",
                          "Gender" = "gender",
                          "Customer type" = "customer_type"),
              selected = c("product_line")
            ),
          actionButton("action_button", "Reset filter"),
          open = "desktop"
        ),
        layout_columns(
          card(
            card_header("Sales evolution by "),
            plotlyOutput("lineplot"),
            full_screen = TRUE
          ),
        ),
        layout_columns(
          card(
            card_header("Output 2"),
            dataTableOutput("wal_data"),
            full_screen = TRUE
          ),
          card(
            card_header("Output 3"),
            dataTableOutput("wal_data"),
            full_screen = TRUE
          ),
          col_widths = c(6, 6)
        )
      
    )

)

# Server
server <- function(input, output, session) {
  filtered_data <- reactive({
    walmart_data  |>
      filter( if (input$input_branch=='all') {branch %in% c('A','B','C')}
              else {branch %in% input$input_branch}
      ) |>
      group_by(date, !!sym(input$input_comparison)) |> 
      summarize(total = sum(total))
    
  })
  
  output$wal_data <- renderDataTable({
    filtered_data()
  })
  
  output$lineplot <- renderPlotly({
    plot <- ggplot(filtered_data(), aes(x=date, y=total, fill=!!sym(input$input_comparison))) +
      geom_area() +
      scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 week") +
      labs(x='Date', y='Total sales ($)', , fill = str_replace(str_to_title(input$input_comparison), "_", " "))
  

    ggplotly(plot)
  })
  
}

shinyApp(ui = ui, server = server)
