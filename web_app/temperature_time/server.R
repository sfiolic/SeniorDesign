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
library(tidyr)
library(mailR)
library(rJava)
library(xts)
library(dplyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  # subject to change
  df_true <- data.frame(Data = unlist(download(projectURL = "https://senior-design-lab-1-d0500.firebaseio.com",
                                                     fileName = "temperature")))
  df_true <- separate(data = df_true, col = Data, into = c("Temperature", "Time"), sep = "\\,") %>% mutate(Temperature = as.numeric(Temperature))
  df_true$Time <- strptime(df_true$Time, "%a %b %d %H:%M:%S %Y")
  
  
  # enable switch
  values <- reactiveValues()
  values$enable <- FALSE
  values$lcd <- 1
  
  autoInvalidate <- reactiveTimer(1000)
  

  
  # max
  # min 
  # phone number
  # flush data frame every 100 data points
  
  observe({
    input$lcd
    
    if (isolate(values$lcd) == 1)
    {
      values$lcd = 0
      output$switch <- renderText({"LCD is On"})
    }
    else {
      values$lcd = 1
      output$switch <- renderText({"LCD is Off"})
    }
    v <- isolate(values$lcd)
    check <- upload(list(str(v)), projectURL = "https://senior-design-lab-1-d0500.firebaseio.com", directory = "LCD")
    print(check)
    
    
    
  })
  
  observe({
    # maybe button instead
    # autoInvalidate()
    invalidateLater(8000)
    if(max(df_true$Temperature) > isolate(input$max)){
      # Verizon: number@vtext.com
      # AT&T: number@txt.att.net
      # other carriers: https://20somethingfinance.com/how-to-send-text-messages-sms-via-email-for-free/
      phone_number <- NULL
      if (isolate(input$icons == 'Verizon')){
        phone_number <- paste0(isolate(input$phone), "@vtext.com")
      }
      else if (isolate(input$icons == 'AT&T')){
        phone_number <- paste0(isolate(input$phone), "@txt.att.net")
      }
      

      send.mail(from = "chichinwakama@gmail.com",
                to = phone_number,
                subject="Sensor Alert: Max Senors",
                body =paste("Failed Sensors! Maximum Limit: ",max(df_true$Temperature)),
                smtp = list(host.name = "smtp.gmail.com", port = 465,
                            user.name="chichinwakama@gmail.com", passwd="chibuzo12", ssl=TRUE),
                authenticate = TRUE,
                send = TRUE)
    }
  })

  
  observe({
    # autoInvalidate()
    invalidateLater(8000)
    if(min(df_true$Temperature) < isolate(input$min)){
      send.mail(from = "chichinwakama@gmail.om",
                to = paste0(isolate(input$phone), "@vtext.com"),
                subject="Sensor Alert: Minimum Sensors",
                body =paste("Failed Sensors! Minimum Limit: ",min(df_true$Temperature)),
                smtp = list(host.name = "smtp.gmail.com", port = 465,
                            user.name="chichinwakama@gmail.com", passwd="chibuzo12", ssl=TRUE),
                authenticate = TRUE,
                send = TRUE)
    }
  })
   
  output$plot <- renderDygraph({
    # autoInvalidate()
    invalidateLater(2000)
    df <- data.frame(Data = unlist(download(projectURL = "https://senior-design-lab-1-d0500.firebaseio.com",
                                 fileName = "temperature")))
    df <- separate(data = df, col = Data, into = c("Temperature", "Time"), sep = "\\,") %>% mutate(Temperature = as.numeric(Temperature))
    df$Time <- strptime(df$Time, "%a %b %d %H:%M:%S %Y")
    
    df_new <- df[!(row.names(df) %in% row.names(df_true)),]
    
    # print(nrow(df_new))
    # print(nrow(df))
    
    if (nrow(df_new) == 0 && isolate(values$enable))
    {
      print("Device is off")
    }
    else 
    {
      df_true <- rbind(df_true, df_new)
      print("Device is on")
      values$enable <- TRUE
    }
    
    
    
    # convert to xts object before using dygraph
    x3<- xts(df_true, order.by=df_true$Time) 
    dygraph(x3) %>% dyRangeSelector(height = 20) %>% dyOptions(colors = RColorBrewer::brewer.pal(8, "Dark2"), connectSeparatedPoints = TRUE)
  })
  
  output$current <- renderText({
    tail(df_true, 1)$Temperature   
  })
  
  output$time <- renderText({
    as.character(tail(df_true, 1)$Time)   
  })
  
})
