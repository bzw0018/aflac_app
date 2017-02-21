library(shiny)
library(shinydashboard)
library(quantmod)

credentials <- list("bin" = "weng")

shinyServer(function(input, output) {

  USER <- reactiveValues(Logged = FALSE)
  
  observeEvent(input$.login, {
    if (isTRUE(credentials[[input$.username]]==input$.password)){
      USER$Logged <- TRUE
    } else {
      show("message")
      output$message = renderText("Invalid user name or password")
      delay(2000, hide("message", anim = TRUE, animType = "fade"))
    }
  })
  
  output$app = renderUI(
    if (!isTRUE(USER$Logged)) {
      fluidRow(column(width=4, offset = 4,
        wellPanel(id = "login",
          textInput(".username", "Username:"),
          passwordInput(".password", "Password:"),
          div(actionButton(".login", "Log in"), style="text-align: center;")
        ),
        textOutput("message")
      ))
    } else {
        # Sidebar with a slider input for number of bins
        sidebarLayout(position = 'right',
            sidebarPanel(helpText('Select an Index and period to analyze. 
                      Information will be collected from Yahoo Finance.'),
                         textInput('start_date','Choose start date',Sys.Date()-730),
                         textInput('end_date','Choose end date',Sys.Date()),
                         radioButtons('stock','Select the ticker',
                                      list('AFL','ALL','MET'),
                                      selected = 'AFL'),
                         actionButton('run','Update')
            ),         
         
          
          # Show a plot of the generated distribution
          mainPanel(
               tabsetPanel(type = 'tab',
                           tabPanel('Introduction',
                                    includeMarkdown('abstract.md')),
                           tabPanel('Stock Market',
                                    h3(helpText('Stock Market Data From Yahoo Finance')),
                                    plotOutput("yahooPlot"))
               )
          )
        )
      
    }

  )
  
  output$period = renderText({paste('The training period is from',
                                    input$start_date, 'to',
                                    input$end_date)})
  output$index = renderText({paste('The index to predit is',
                                   input$stock)})
  yahooData = eventReactive(input$run, {
       getSymbols(input$stock, src = 'yahoo', from = input$start_date,
                  to = input$end_date, auto.assign = FALSE)
  })
  
  output$yahooPlot = renderPlot({
       chartSeries(yahooData(),theme = 'white', type = 'line')
  })
  
  
})
