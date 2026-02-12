library(shiny)
library(readxl)
library(fs)

ui <- fluidPage(
  titlePanel("Posit Assistant File Import"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("folder",
                  "Select Folder:",
                  choices = NULL),
      
      selectInput("workbook",
                  "Select Excel Workbook:",
                  choices = NULL),
      
      selectInput("sheet",
                  "Select Sheet:",
                  choices = NULL),
      
      actionButton("import", "Import Data", class = "btn-primary")
    ),
    
    mainPanel(
      h4("Dataset Name:"),
      verbatimTextOutput("dataset_name"),
      
      h4("Head of Data:"),
      verbatimTextOutput("data_head"),
      
      h4("Structure:"),
      verbatimTextOutput("data_structure")
    )
  )
)

server <- function(input, output, session) {
  
  # Reactive value to store imported data
  imported_data <- reactiveVal(NULL)
  
  # Initialize folder list
  observe({
    # Get subfolders starting from Downloads
    base_folder <- "C:/Users/bdeci/Downloads"
    
    # Get all subdirectories
    if (dir.exists(base_folder)) {
      folders <- c(base_folder, list.dirs(base_folder, full.names = TRUE, recursive = FALSE))
      updateSelectInput(session, "folder", choices = folders, selected = base_folder)
    } else {
      showNotification("Downloads folder not found!", type = "error")
    }
  })
  
  # Update workbook list when folder changes
  observeEvent(input$folder, {
    req(input$folder)
    
    if (dir.exists(input$folder)) {
      # Find all Excel files in selected folder
      excel_files <- list.files(input$folder, 
                                pattern = "\\.(xlsx|xls)$", 
                                full.names = FALSE,
                                ignore.case = TRUE)
      
      if (length(excel_files) > 0) {
        updateSelectInput(session, "workbook", 
                         choices = excel_files,
                         selected = excel_files[1])
      } else {
        updateSelectInput(session, "workbook", choices = NULL)
        showNotification("No Excel files found in this folder", type = "warning")
      }
    }
  })
  
  # Update sheet list when workbook changes
  observeEvent(input$workbook, {
    req(input$folder, input$workbook)
    
    tryCatch({
      file_path <- file.path(input$folder, input$workbook)
      
      if (file.exists(file_path)) {
        sheets <- excel_sheets(file_path)
        updateSelectInput(session, "sheet", 
                         choices = sheets,
                         selected = sheets[1])
      }
    }, error = function(e) {
      showNotification(paste("Error reading workbook:", e$message), type = "error")
    })
  })
  
  # Import data when button is clicked
  observeEvent(input$import, {
    req(input$folder, input$workbook, input$sheet)
    
    tryCatch({
      file_path <- file.path(input$folder, input$workbook)
      
      # Read the Excel file
      data <- read_excel(file_path, sheet = input$sheet)
      imported_data(data)
      
      showNotification("Data imported successfully!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error importing data:", e$message), type = "error")
    })
  })
  
  # Display dataset name
  output$dataset_name <- renderText({
    req(imported_data())
    paste0("imported_data (", nrow(imported_data()), " rows, ", 
           ncol(imported_data()), " columns)")
  })
  
  # Display head of data
  output$data_head <- renderPrint({
    req(imported_data())
    head(imported_data())
  })
  
  # Display structure
  output$data_structure <- renderPrint({
    req(imported_data())
    str(imported_data())
  })
}

shinyApp(ui = ui, server = server)
