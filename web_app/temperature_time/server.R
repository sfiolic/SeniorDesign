#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dygraphs)
library(fireData)
library(ggplot2)
library(scales)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  autoInvalidate <- reactiveTimer(1000)
  
  # observe({
  #   autoInvalidate()
  #   df <- as.data.frame(download(projectURL = "https://senior-design-lab-1-d0500.firebaseio.com",
  #                          fileName = "temp"))
  # })
  
  # df <- as.data.frame(download(projectURL = "https://senior-design-lab-1-d0500.firebaseio.com", 
                               #fileName = "temp"))
   
  output$plot <- renderDygraph({
    autoInvalidate()
    df <- as.data.frame(download(projectURL = "https://senior-design-lab-1-d0500.firebaseio.com",
                                 fileName = "temp"))
    df$Time<-strptime(df$Time, "%m/%d/%y %I:%M:%S %p") 
    
    # convert to xts object before using dygraph
    x3<- xts(df, order.by=df$Time) 
    dygraph(x3) %>% dyRangeSelector(height = 20)
    
  })
  
})
