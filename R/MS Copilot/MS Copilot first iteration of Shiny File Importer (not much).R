## MS code for a Shiny app that allows users to import Excel files from a specified directory. The app dynamically lists Excel files and their sheets, and imports the selected sheet into the global environment with a dataset name derived from the file name.
## This was done by MS Copilot.

# app.R
library(shiny)
library(readxl)
library(tools)

ui <- fluidPage(
  titlePanel("Excel_Importer"),

  sidebarLayout(
    sidebarPanel(
      textInput("directory", "Enter directory path:", value = getwd()),
      uiOutput("file_ui"),
      uiOutput("sheet_ui"),
      actionButton("import_btn", "Import File")
    ),

    mainPanel(
      verbatimTextOutput("result")
    )
  )
)

server <- function(input, output, session) {

  # Dynamically list Excel files in the directory
  output$file_ui <- renderUI({
    req(input$directory)

    files <- list.files(input$directory, pattern = "\\.xlsx?$", full.names = FALSE)
    selectInput("file", "Select Excel file:", choices = files)
  })

  # Dynamically list sheets in the selected workbook
  output$sheet_ui <- renderUI({
    req(input$directory, input$file)

    file_path <- file.path(input$directory, input$file)
    sheets <- excel_sheets(file_path)

    selectInput("sheet", "Select sheet:", choices = sheets)
  })

  # Import the selected sheet into the global environment
  observeEvent(input$import_btn, {
    req(input$directory, input$file, input$sheet)

    file_path <- file.path(input$directory, input$file)

    # Create dataset name from file name (without extension)
    dataset_name <- make.names(file_path_sans_ext(input$file))

    # Read the sheet
    data <- read_excel(file_path, sheet = input$sheet)

    # Assign to global environment
    assign(dataset_name, data, envir = .GlobalEnv)

    # Display dataset name
    output$result <- renderText({
      paste("Imported dataset created in environment:", dataset_name)
    })
  })
}

shinyApp(ui, server)
