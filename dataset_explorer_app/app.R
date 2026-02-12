library(shiny)
library(tidyverse)
library(patchwork)

# UI
ui <- fluidPage(
  titlePanel("Dataset Explorer and Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset", "Choose a dataset:",
                  choices = c("airquality", "mtcars", "iris", "faithful", 
                              "ChickWeight", "ToothGrowth", "PlantGrowth")),
      hr(),
      h4("Dataset Info"),
      verbatimTextOutput("dataInfo"),
      hr(),
      uiOutput("timeseriesUI")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Data Preview",
                 h3("First Rows"),
                 tableOutput("dataHead"),
                 h3("Summary Statistics"),
                 verbatimTextOutput("dataSummary")),
        
        tabPanel("Missing Data",
                 h3("Missing Values by Variable"),
                 tableOutput("missingTable"),
                 plotOutput("missingPlot")),
        
        tabPanel("Distributions",
                 h3("Variable Distributions"),
                 plotOutput("distPlots", height = "600px")),
        
        tabPanel("Relationships",
                 h3("Variable Relationships"),
                 plotOutput("relPlots", height = "600px")),
        
        tabPanel("Time Series",
                 uiOutput("timeseriesContent"))
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive dataset
  dataset <- reactive({
    get(input$dataset)
  })
  
  # Dataset info
  output$dataInfo <- renderText({
    df <- dataset()
    paste0(
      "Rows: ", nrow(df), "\n",
      "Columns: ", ncol(df), "\n",
      "Variables: ", paste(names(df), collapse = ", ")
    )
  })
  
  # Data preview
  output$dataHead <- renderTable({
    head(dataset(), 10)
  })
  
  # Summary statistics
  output$dataSummary <- renderPrint({
    summary(dataset())
  })
  
  # Missing data table
  output$missingTable <- renderTable({
    df <- dataset()
    missing_counts <- df |>
      summarise(across(everything(), ~sum(is.na(.)))) |>
      pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Count") |>
      mutate(Percent = round(Missing_Count / nrow(df) * 100, 1))
    missing_counts
  }, digits = 1)
  
  # Missing data plot
  output$missingPlot <- renderPlot({
    df <- dataset()
    missing_data <- df |>
      summarise(across(everything(), ~sum(is.na(.)))) |>
      pivot_longer(everything(), names_to = "Variable", values_to = "Count")
    
    if (sum(missing_data$Count) == 0) {
      plot.new()
      text(0.5, 0.5, "No missing values in this dataset!", cex = 1.5)
    } else {
      missing_data |>
        filter(Count > 0) |>
        ggplot(aes(x = reorder(Variable, Count), y = Count)) +
        geom_col(fill = "coral", alpha = 0.7) +
        coord_flip() +
        labs(x = "Variable", y = "Number of Missing Values",
             title = "Missing Values by Variable") +
        theme_minimal()
    }
  })
  
  # Distribution plots
  output$distPlots <- renderPlot({
    df <- dataset()
    numeric_vars <- df |> select(where(is.numeric)) |> names()
    
    if (length(numeric_vars) == 0) {
      plot.new()
      text(0.5, 0.5, "No numeric variables to plot", cex = 1.5)
      return()
    }
    
    # Limit to first 6 numeric variables
    numeric_vars <- numeric_vars[1:min(6, length(numeric_vars))]
    
    plots <- lapply(numeric_vars, function(var) {
      ggplot(df, aes(x = !!sym(var))) +
        geom_histogram(bins = 20, fill = "steelblue", alpha = 0.7) +
        labs(title = var, x = var, y = "Count") +
        theme_minimal()
    })
    
    wrap_plots(plots, ncol = 2)
  })
  
  # Relationship plots
  output$relPlots <- renderPlot({
    df <- dataset()
    numeric_vars <- df |> select(where(is.numeric)) |> names()
    
    if (length(numeric_vars) < 2) {
      plot.new()
      text(0.5, 0.5, "Need at least 2 numeric variables for relationships", cex = 1.5)
      return()
    }
    
    # Create scatter plots for first few numeric variables
    if (length(numeric_vars) >= 3) {
      # Use first variable as y, others as x
      y_var <- numeric_vars[1]
      x_vars <- numeric_vars[2:min(4, length(numeric_vars))]
      
      plots <- lapply(x_vars, function(x_var) {
        ggplot(df, aes(x = !!sym(x_var), y = !!sym(y_var))) +
          geom_point(alpha = 0.6, color = "steelblue") +
          labs(title = paste(y_var, "vs", x_var), x = x_var, y = y_var) +
          theme_minimal()
      })
      
      wrap_plots(plots, ncol = 2)
    } else {
      # Just one scatter plot
      ggplot(df, aes(x = !!sym(numeric_vars[1]), y = !!sym(numeric_vars[2]))) +
        geom_point(alpha = 0.6, color = "steelblue") +
        labs(x = numeric_vars[1], y = numeric_vars[2]) +
        theme_minimal()
    }
  })
  
  # Time series UI (conditional)
  output$timeseriesUI <- renderUI({
    df <- dataset()
    # Check if dataset has time-related columns
    has_date_cols <- any(c("Month", "Day", "Time", "time", "Date", "date") %in% names(df))
    
    if (has_date_cols) {
      tagList(
        h4("Time Series Options"),
        selectInput("ts_yvar", "Y Variable:", 
                    choices = names(df |> select(where(is.numeric))))
      )
    }
  })
  
  # Time series content
  output$timeseriesContent <- renderUI({
    df <- dataset()
    
    if (input$dataset == "airquality" && all(c("Month", "Day") %in% names(df))) {
      plotOutput("timeseriesPlot", height = "500px")
    } else if ("Time" %in% names(df) || "time" %in% names(df)) {
      plotOutput("timeseriesPlot", height = "500px")
    } else {
      div(
        style = "padding: 20px;",
        h4("Time Series Not Available"),
        p("This dataset doesn't have recognizable time/date columns for time series analysis.")
      )
    }
  })
  
  # Time series plot
  output$timeseriesPlot <- renderPlot({
    df <- dataset()
    
    if (input$dataset == "airquality") {
      df_ts <- df |>
        mutate(Date = as.Date(paste("1973", Month, Day, sep = "-")))
      
      y_var <- if (!is.null(input$ts_yvar)) input$ts_yvar else "Ozone"
      
      ggplot(df_ts, aes(x = Date, y = !!sym(y_var))) +
        geom_line(color = "steelblue", alpha = 0.7, na.rm = TRUE) +
        geom_point(color = "steelblue", size = 2, alpha = 0.5, na.rm = TRUE) +
        scale_x_date(date_breaks = "1 month", date_labels = "%b") +
        labs(
          title = paste("Daily", y_var, "Levels: May-September 1973"),
          x = "Date",
          y = y_var
        ) +
        theme_minimal()
    } else if ("Time" %in% names(df)) {
      y_var <- if (!is.null(input$ts_yvar)) input$ts_yvar else names(df |> select(where(is.numeric)))[1]
      
      ggplot(df, aes(x = Time, y = !!sym(y_var))) +
        geom_line(color = "steelblue") +
        geom_point(color = "steelblue", alpha = 0.5) +
        labs(title = paste(y_var, "over Time"), x = "Time", y = y_var) +
        theme_minimal()
    }
  })
}

# Run app
shinyApp(ui = ui, server = server)
