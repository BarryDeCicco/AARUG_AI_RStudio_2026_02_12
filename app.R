library(shiny)
library(readxl)
library(bslib)

ui <- page_sidebar(
  title = "Excel File Importer",
  sidebar = sidebar(
    width = 300,
    h4("Import Excel File"),
    actionButton("select_folder", "1. Select Folder", 
                 class = "btn-primary", width = "100%"),
    verbatimTextOutput("folder_path"),
    br(),
    actionButton("select_file", "2. Select Excel File", 
                 class = "btn-primary", width = "100%"),
    verbatimTextOutput("file_path"),
    br(),
    actionButton("select_sheet", "3. Select Sheet", 
                 class = "btn-primary", width = "100%"),
    verbatimTextOutput("sheet_name")
  ),
  card(
    card_header("Import Results"),
    verbatimTextOutput("dataset_name"),
    hr(),
    h5("Head of Dataset:"),
    verbatimTextOutput("data_head"),
    hr(),
    h5("Structure:"),
    verbatimTextOutput("data_str")
  )
)

server <- function(input, output, session) {
  
  # Reactive values to store selections
  rv <- reactiveValues(
    folder = NULL,
    file = NULL,
    sheet = NULL,
    data = NULL,
    dataset_name = NULL
  )
  
  # Select folder
  observeEvent(input$select_folder, {
    folder <- choose.dir(default = getwd(), caption = "Select Folder")
    if (!is.null(folder)) {
      rv$folder <- folder
      rv$file <- NULL
      rv$sheet <- NULL
      rv$data <- NULL
    }
  })
  
  output$folder_path <- renderText({
    if (!is.null(rv$folder)) {
      paste("Selected:", basename(rv$folder))
    } else {
      "No folder selected"
    }
  })
  
  # Select Excel file
  observeEvent(input$select_file, {
    if (is.null(rv$folder)) {
      showNotification("Please select a folder first!", type = "warning")
      return()
    }
    
    file <- file.choose()
    if (!is.null(file) && grepl("\\.(xlsx|xls)$", file, ignore.case = TRUE)) {
      rv$file <- file
      rv$sheet <- NULL
      rv$data <- NULL
    } else if (!is.null(file)) {
      showNotification("Please select an Excel file (.xlsx or .xls)", type = "error")
    }
  })
  
  output$file_path <- renderText({
    if (!is.null(rv$file)) {
      paste("Selected:", basename(rv$file))
    } else {
      "No file selected"
    }
  })
  
  # Select sheet
  observeEvent(input$select_sheet, {
    if (is.null(rv$file)) {
      showNotification("Please select an Excel file first!", type = "warning")
      return()
    }
    
    sheets <- excel_sheets(rv$file)
    
    showModal(modalDialog(
      title = "Select Sheet",
      selectInput("sheet_select", "Choose a sheet:", choices = sheets),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_sheet", "Import", class = "btn-primary")
      )
    ))
  })
  
  observeEvent(input$confirm_sheet, {
    rv$sheet <- input$sheet_select
    
    # Import the data
    tryCatch({
      rv$data <- read_excel(rv$file, sheet = rv$sheet)
      
      # Create dataset name based on file and sheet
      file_base <- tools::file_path_sans_ext(basename(rv$file))
      sheet_clean <- gsub("[^[:alnum:]_]", "_", rv$sheet)
      rv$dataset_name <- paste0(file_base, "_", sheet_clean)
      
      # Assign to global environment
      assign(rv$dataset_name, rv$data, envir = .GlobalEnv)
      
      showNotification(
        paste("Successfully imported:", rv$dataset_name), 
        type = "message",
        duration = 5
      )
      
      removeModal()
      
    }, error = function(e) {
      showNotification(
        paste("Error importing file:", e$message), 
        type = "error"
      )
    })
  })
  
  output$sheet_name <- renderText({
    if (!is.null(rv$sheet)) {
      paste("Selected:", rv$sheet)
    } else {
      "No sheet selected"
    }
  })
  
  # Display dataset name
  output$dataset_name <- renderText({
    if (!is.null(rv$dataset_name)) {
      paste("Dataset created:", rv$dataset_name)
    } else {
      "No data imported yet"
    }
  })
  
  # Display head of data
  output$data_head <- renderPrint({
    if (!is.null(rv$data)) {
      head(rv$data)
    } else {
      cat("No data to display")
    }
  })
  
  # Display structure
  output$data_str <- renderPrint({
    if (!is.null(rv$data)) {
      str(rv$data)
    } else {
      cat("No data to display")
    }
  })
}

shinyApp(ui = ui, server = server)
