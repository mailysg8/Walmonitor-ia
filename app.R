library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(ggplot2)
library(stringr)

# Load data
walmart_data <- read.csv(
  "data/walmart_sales_data.csv"
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

# Helper function
compare <- function(current, baseline) {
  pct = round((current - baseline) / abs(baseline) * 100,2)
  sign = if (pct >= 0) {"+"} else {""}
  badge = paste0(sign, pct, "% compared to January average (",round(baseline,2), "$)")
  return(badge)
}

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
          value_box(
            title = "Average Sales",
            value = textOutput("avg_sales"),
            p(textOutput("avg_sales_compare"))
          ),
          value_box(
            title = "Max Sales",
            value = textOutput("max_sales"),
            p(textOutput("max_date")),
            p(textOutput("max_type"))
          ),
          value_box(
            title = "Min Sales",
            value = textOutput("min_sales"),
            p(textOutput("min_date")),
            p(textOutput("min_type"))
          ),
          fill = FALSE
        ),
        layout_columns(
          card(
            card_header("Sales evolution"),
            plotlyOutput("lineplot"),
            full_screen = TRUE
          ),
        )
      
    )

)

# Server
server <- function(input, output, session) {
  filtered_data <- reactive({
    walmart_data  |>
      filter( (if (input$input_branch=='all') {branch %in% c('A','B','C')}
              else {branch %in% input$input_branch})
      ) |>
      group_by(date, !!sym(input$input_comparison)) |> 
      summarize(total = sum(total))
    
  })
  
  output$avg_sales <- renderText({
    avg_df <- filtered_data() |> 
      filter(between(date,as.Date("2019-02-01"), as.Date("2019-03-31")))  
    
    avg <- mean(avg_df$total)
  
    paste0(round(avg,2),"$")
  })
  
  output$avg_sales_compare <- renderText({
    jan_df <- filtered_data() |> 
      filter(between(date,as.Date("2019-01-01"), as.Date("2019-01-31"))) 
    
    jan_avg <- mean(jan_df$total)
    
    avg_df <- filtered_data() |> 
      filter(between(date,as.Date("2019-02-01"), as.Date("2019-03-31")))  
    
    avg <- mean(avg_df$total)
    
    compare(avg, jan_avg)
  })
  
  output$max_sales <- renderText({
    max_df <- filtered_data() |>  arrange(desc(total))
    paste0(round(max_df$total[1],2),"$")
  })
  
  output$max_date <- renderText({
    max_df <- filtered_data() |>  arrange(desc(total))
    paste0("Reached on : ",max_df$date[1])
  })
  
  output$max_type <- renderText({
    max_df <- filtered_data() |>  arrange(desc(total))
    paste0(str_replace(str_to_title(input$input_comparison), "_", " ") , " : ", max_df[1,2])
  })
  
  output$min_sales <- renderText({
    min_df <- filtered_data() |>  arrange(total)
    paste0(round(min_df$total[1],2),"$")
  })
  
  output$min_date <- renderText({
    min_df <- filtered_data() |>  arrange(total)
    paste0("Reached on : ",min_df$date[1])
  })
  
  output$min_type <- renderText({
    min_df <- filtered_data() |>  arrange(total)
    paste0(str_replace(str_to_title(input$input_comparison), "_", " ") , " : ", min_df[1,2])
  })
  
  output$lineplot <- renderPlotly({
    df <- filtered_data() |> 
      filter(between(date,as.Date("2019-02-01"), as.Date("2019-03-31")))
    
    plot <- ggplot(df, aes(x=date, y=total, fill=!!sym(input$input_comparison))) +
      geom_area() +
      scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 week") +
      labs(x='Date', y='Total sales ($)', , fill = str_replace(str_to_title(input$input_comparison), "_", " "))
  

    ggplotly(plot)
  })
  
}

shinyApp(ui = ui, server = server)
