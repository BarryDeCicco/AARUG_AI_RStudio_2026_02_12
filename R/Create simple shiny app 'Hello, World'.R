

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


# turn off the above app
# To turn off the Shiny app, you can simply stop the R session or press the "Stop" button in your R environment (such as RStudio) where the app is running. If you are running the app in a terminal, you can use Ctrl + C to stop it.
























