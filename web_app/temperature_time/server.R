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
  df_true <- separate(data = df_true, col = Data, into = c("TemperatureC", "TemperatureF", "Time"), sep = "\\,") %>% 
    mutate(TemperatureC = as.numeric(TemperatureC), TemperatureF = as.numeric(TemperatureF), Temperature = TemperatureC)
  df_true$Time <- strptime(df_true$Time, "%a %b %d %H:%M:%S %Y")
  
  df_new <- df_true
  
  # enable switch
  values <- reactiveValues()
  values$enable = FALSE
  values$cf = TRUE
  values$lcd = 1
  values$t = "C"
  values$df <- df_true
  values$sensor <- NULL
  
  # autoInvalidate <- reactiveTimer(1000)
  
  observe({
    invalidateLater(2000)
    df <- data.frame(Data = unlist(download(projectURL = "https://senior-design-lab-1-d0500.firebaseio.com",
                                            fileName = "temperature")))
    df <- separate(data = df, col = Data, into = c("TemperatureC", "TemperatureF", "Time"), sep = "\\,") %>% 
      mutate(TemperatureC = as.numeric(TemperatureC), TemperatureF = as.numeric(TemperatureF), Temperature = TemperatureC)
    df$Time <- strptime(df$Time, "%a %b %d %H:%M:%S %Y")
    
    df_true <- isolate(values$df)
    df_new <- df[!(row.names(df) %in% row.names(df_true)),]
    
    print(dim(df_new))
    
    if (nrow(df_new) == 0 && isolate(values$enable))
    {
      values$sensor = "No Data is Available"
      # output$current <- renderText({
      #   
      # })
      
      #print(dim(df_true))
      empty <- c(TemperatureC = NA, TemperatureF = NA, Temperature = NULL, Time = NA)
      val <- tail(df_true, 1)[1, 'Time'] + 2
      
      #print(val)
      
      
      df_true <- rbind(df_true, empty)
      df_true[nrow(df_true), 'Time'] <- val
      #df_true[nrow(df_true), 'Temperature'] <- 1000
      
      #print(dim(df_true))
      
      
      
    }
    else if (any(df_new$Temperature <= -127) ){
      values$sensor = "Unplugged Sensor"
      # output$current <- renderText({
      #   "Unplugged Sensor"
      # })
      
      #print(dim(df_true))
      empty <- c(TemperatureC = NA, TemperatureF = NA, Temperature = NULL, Time = NA)
      val <- tail(df_true, 1)[1, 'Time'] + 2
      
      #print(val)
      df_true <- rbind(df_true, empty)
      df_true[nrow(df_true), 'Time'] <- val
      #df_true[nrow(df_true), 'Temperature'] <- 1000
      
      values$df <- df_true
      #print(dim(df_true))
    }
    else
    {
      df_true <- rbind(df_true, df_new)
      values$sensor <- tail(df_true, 1)$Temperature
      # output$current <- renderText({
      #   tail(df_true, 1)$Temperature
      # })
      values$enable <- TRUE
    }
    
    # df_true <- rbind(df_true, df_new)
    
    
    values$df <- df_true
    values$tt <-  as.character(tail(df_true, 1)$Time)   
    #print(tail(values$df, 5))
  })
  

  observe({
    input$cf

    if (isolate(values$cf) == TRUE){
      df_true[, 'Temperature'] <- df_true[, 'TemperatureF']
      values$cf = FALSE
      values$t = 'F'
    }
    else {
      df_true[, 'Temperature'] <- df_true[, 'TemperatureC']
      values$cf = TRUE
      values$t = 'C'
      
    }
    
    # print(values$t)
    # print(values$cf)

  })
  
  # max
  # min 
  # phone number
  # flush data frame every 100 data points
  
  observe({
    input$lcd
    
    if (isolate(values$lcd) == 1)
    {
      lcd = 0
      values$lcd = 0
      output$switch <- renderText({"LCD is On"})
    }
    else {
      lcd = 1
      values$lcd = 1
      output$switch <- renderText({"LCD is Off"})
    }
    
    put(list(lcd), projectURL = "https://senior-design-lab-1-d0500.firebaseio.com", directory = "LCD")
    
  })
  
  observe({
    # maybe button instead
    # autoInvalidate()
    invalidateLater(8000)
    #print(input$max)
    if(is.numeric(input$max) && max(df_new$Temperature) > isolate(input$max)){
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
                subject="Sensor Alert:",
                body =paste("Sensor exceeded max temp:",max(df_new$Temperature), "at", 
                            as.character(df_new[df_new$Temperature >= max(df_new$Temperature), ][1, 'Time'])),
                smtp = list(host.name = "smtp.gmail.com", port = 465,
                            user.name="chichinwakama@gmail.com", passwd="chibuzo12", ssl=TRUE),
                authenticate = TRUE,
                send = TRUE)
    }
  })

  
  observe({
    # autoInvalidate()
    invalidateLater(8000)
    
    if (isolate(input$icons == 'Verizon')){
      phone_number <- paste0(isolate(input$phone), "@vtext.com")
    }
    else if (isolate(input$icons == 'AT&T')){
      phone_number <- paste0(isolate(input$phone), "@txt.att.net")
    }
    
    
    if(is.numeric(input$min) && min(df_new$Temperature) < isolate(input$min)){
      send.mail(from = "chichinwakama@gmail.om",
                to = phone_number,
                subject="Sensor Alert:",
                body =paste("Sensor value reached below min temp: ",min(df_true$Temperature), "at", 
                            as.character(df_new[df_new$Temperature >= max(df_new$Temperature), ][1, 'Time'])),
                smtp = list(host.name = "smtp.gmail.com", port = 465,
                            user.name="chichinwakama@gmail.com", passwd="chibuzo12", ssl=TRUE),
                authenticate = TRUE,
                send = TRUE)
    }
  })
   
  output$plot <- renderDygraph({
    # autoInvalidate()
    invalidateLater(2000)
    
      output$current <- renderText({
        tail(df_true, 1)$Temperature
      })
    
    
    output$time <- renderText({
     isolate(values$tt)
    })
    
    output$current <- renderText({
      isolate( values$sensor)
    })
    
    #df_true <- values$df
    
    #print(dim(isolate(values$df)))
    # convert to xts object before using dygraph
    df_export <- isolate(values$df ) %>% select(Temperature, Time) 
    x3<- xts(df_export, order.by=df_export$Time) 
    dygraph(x3) %>% dyRangeSelector(height = 20) %>% dyAxis("y", label = paste0("Temperature (", isolate(values$t), ")" ), valueRange = c(-100, 100)) %>%
      dyOptions(retainDateWindow = TRUE, connectSeparatedPoints = FALSE)
  })
  
  
  
  
  
})
