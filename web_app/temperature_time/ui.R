#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dygraphs)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Temperature-Time Graph"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(numericInput("min", "Alert Minimum Temperature:", -135), 
                 numericInput("max", "Alert Maximum Temperature:", 100), 
                 textInput("phone", "Phone Number to send Alert Message:", "5078295432"),
                 radioButtons("icons", "Choose Provider:",
                                    choiceNames =
                                      list("Verizon", "AT&T"),
                                    choiceValues =
                                      list("Verizon", "AT&T")
                 ),
                 actionButton('lcd', 'Turn On/Off LCD'),
                 
                 # Output Information  
                 hr(),
                 # TODO: Should be bigger
                 div(h1("Current Temperature: "), h2(textOutput("current", inline = TRUE))),
                 div(h1("Current Time: "), h2(textOutput("time", inline = TRUE))),
                 br(),
                 actionButton('cf', 'Convert °C between °F'),
                 #helpText(textOutput('switch', inline = TRUE)),
                 # div(strong("State of Device: "), textOutput("state", inline = TRUE)),
                 br(),
                 helpText("Click and drag to zoom in (double click to zoom back out).")),  
    
    # Show a plot of the generated distribution
    mainPanel(
      dygraphOutput("plot")
    ))
    
   
))
