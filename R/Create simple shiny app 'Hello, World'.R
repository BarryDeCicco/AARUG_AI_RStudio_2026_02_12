

# create a shiny app which prints 'hello world' when the button is clicked
library(shiny)
ui <- fluidPage(
  actionButton("btn", "Click me"),
  textOutput("text")
)
server <- function(input, output) {
  observeEvent(input$btn, {
    output$text <- renderText("Hello World")
  })
}

shinyApp(ui, server)


























