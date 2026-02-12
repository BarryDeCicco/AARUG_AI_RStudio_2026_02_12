

# Creating the Shiny app 'Excel_Importer' using ClaudeAI:

## session:  https://claude.ai/chat/90fa3a2e-2911-4f95-9b34-565c7c7895ee

## install.packages("shinyFiles")


library(shiny)
library(readxl)
library(shinyFiles)

# Define UI
ui <- fluidPage(
  titlePanel("Excel Importer"),

  sidebarLayout(
    sidebarPanel(
      # Directory selection with browse button
      fluidRow(
        column(9,
               textInput("directory_path",
                         "Directory Path:",
                         value = "C:/Users/bdeci",
                         placeholder = "Enter or browse for directory path")
        ),
        column(3,
               br(),
               shinyDirButton("browse_dir",
                              "Browse...",
                              "Select Directory",
                              style = "margin-top: 0px;")
        )
      ),

      # Display current directory status
      verbatimTextOutput("current_dir"),

      # File selection dropdown
      selectInput("file",
                  "Select Excel File:",
                  choices = NULL),

      # Sheet selection dropdown
      selectInput("sheet",
                  "Select Sheet:",
                  choices = NULL),

      # Dataset name input
      textInput("dataset_name",
                "Dataset Name:",
                value = "imported_data",
                placeholder = "Enter name for dataset"),

      # Import button
      actionButton("import",
                   "Import Data",
                   class = "btn-primary")
    ),

    mainPanel(
      h4("Import Status:"),
      verbatimTextOutput("status"),

      h4("Data Preview:"),
      tableOutput("preview")
    )
  )
)

# Define server logic
server <- function(input, output, session) {

  # Reactive value to store the current file path
  current_file <- reactiveVal(NULL)

  # Set up shinyFiles directory chooser
  # Allow access to entire file system
  roots <- c(Home = path.expand("~"),
             Documents = file.path(path.expand("~"), "Documents"),
             Root = "/")

  # On Windows, add drive letters
  if (.Platform$OS.type == "windows") {
    drives <- paste0(LETTERS, ":/")
    existing_drives <- drives[sapply(drives, dir.exists)]
    roots <- c(roots, setNames(existing_drives, paste0("Drive_", LETTERS[1:length(existing_drives)])))
  }

  shinyDirChoose(input, "browse_dir", roots = roots, session = session)

  # Handle directory selection from browse button
  observeEvent(input$browse_dir, {
    if (!is.integer(input$browse_dir)) {
      dir_path <- parseDirPath(roots, input$browse_dir)
      if (length(dir_path) > 0 && dir_path != "") {
        updateTextInput(session, "directory_path", value = dir_path)
      }
    }
  })

  # Reactive value to get the active directory
  active_directory <- reactive({
    req(input$directory_path)

    dir_path <- input$directory_path

    # Return the path if it exists, otherwise return NULL
    if (!is.null(dir_path) && dir_path != "" && dir.exists(dir_path)) {
      return(dir_path)
    } else {
      return(NULL)
    }
  })

  # Display current directory status
  output$current_dir <- renderText({
    dir <- active_directory()
    if (!is.null(dir)) {
      paste("✓ Valid directory:", dir)
    } else {
      "✗ Invalid directory path"
    }
  })

  # Update file list when directory changes
  observeEvent(active_directory(), {
    dir <- active_directory()

    if (!is.null(dir)) {
      # Get all Excel files in the directory
      files <- list.files(dir,
                          pattern = "\\.(xlsx|xls)$",
                          full.names = FALSE)

      if (length(files) > 0) {
        updateSelectInput(session, "file",
                          choices = c("Select a file..." = "", files))
      } else {
        updateSelectInput(session, "file",
                          choices = c("No Excel files found" = ""))
      }
    } else {
      updateSelectInput(session, "file",
                        choices = c("Invalid directory" = ""))
    }
  })

  # Update sheet list when file changes
  observeEvent(input$file, {
    req(input$file)
    dir <- active_directory()
    req(dir)

    if (input$file != "" && input$file != "Select a file..." &&
        input$file != "No Excel files found" && input$file != "Invalid directory") {

      file_path <- file.path(dir, input$file)
      current_file(file_path)

      tryCatch({
        sheets <- excel_sheets(file_path)
        updateSelectInput(session, "sheet",
                          choices = c("Select a sheet..." = "", sheets))
      }, error = function(e) {
        updateSelectInput(session, "sheet",
                          choices = c("Error reading file" = ""))
      })
    } else {
      updateSelectInput(session, "sheet", choices = NULL)
    }
  })

  # Import data when button is clicked
  observeEvent(input$import, {
    req(input$file, input$sheet, input$dataset_name)

    if (input$sheet == "" || input$sheet == "Select a sheet..." ||
        input$sheet == "Error reading file") {
      output$status <- renderText("Please select a valid sheet")
      return()
    }

    tryCatch({
      # Read the Excel file
      data <- read_excel(current_file(), sheet = input$sheet)

      # Assign to global environment with user-specified name
      assign(input$dataset_name, data, envir = .GlobalEnv)

      # Output success message with dataset name
      output$status <- renderText({
        paste0("Successfully imported data as: '", input$dataset_name, "'\n",
               "Dimensions: ", nrow(data), " rows × ", ncol(data), " columns")
      })

      # Show preview of the data
      output$preview <- renderTable({
        head(data, 10)
      })

    }, error = function(e) {
      output$status <- renderText(paste("Error importing file:", e$message))
      output$preview <- renderTable(NULL)
    })
  })

  # Initial status message
  output$status <- renderText("Select a directory, file, and sheet to import")
}

# Run the application
shinyApp(ui = ui, server = server)





