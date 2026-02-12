## MS code for a Shiny app that allows users to import Excel files from a specified directory. The app dynamically lists Excel files and their sheets, and imports the selected sheet into the global environment with a dataset name derived from the file name.
## This was done by MS Copilot.

# app.R
library(shiny)
library(shinyFiles)
library(readxl)
library(tools)

ui <- fluidPage(
  titlePanel("Excel_Importer"),

  sidebarLayout(
    sidebarPanel(
      shinyDirButton("dir", "Select directory", "Choose a folder"),
      verbatimTextOutput("dir_path"),

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

  # Set default root (Windows)
  roots <- c(home = "C:/Users/bdeci")

  # Directory chooser
  shinyDirChoose(input, "dir", roots = roots, session = session)

  # Reactive directory path
  directory <- reactive({
    req(input$dir)
    normalizePath(parseDirPath(roots, input$dir))
  })

  output$dir_path <- renderText({
    req(directory())
    paste("Selected directory:", directory())
  })

  # Dynamically list Excel files in the selected directory
  output$file_ui <- renderUI({
    req(directory())

    files <- list.files(directory(), pattern = "\\.xlsx?$", full.names = FALSE)
    selectInput("file", "Select Excel file:", choices = files)
  })

  # Dynamically list sheets in the selected workbook
  output$sheet_ui <- renderUI({
    req(directory(), input$file)

    file_path <- file.path(directory(), input$file)
    sheets <- excel_sheets(file_path)

    selectInput("sheet", "Select sheet:", choices = sheets)
  })

  # Import the selected sheet into the global environment
  observeEvent(input$import_btn, {
    req(directory(), input$file, input$sheet)

    file_path <- file.path(directory(), input$file)

    dataset_name <- make.names(file_path_sans_ext(input$file))
    data <- read_excel(file_path, sheet = input$sheet)

    assign(dataset_name, data, envir = .GlobalEnv)

    output$result <- renderText({
      paste("Imported dataset created in environment:", dataset_name)
    })
  })
}

shinyApp(ui, server)
