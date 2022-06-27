library(shiny)
library(googleway)
library(shinydashboard)
library(googleway)
library(jsonlite)
library(data.table)
library(httr)
library(plotly)
library(DBI)
library(RODBC)
library(ggplot2)
library(odbc)
library(dashboardthemes)
library(shinyWidgets)
library(tidyr)
library(dplyr)
source("about.R")

con <- dbConnect(odbc(),
                 # Driver='DataDirect 8.0 PostgreSQL Wire Protocol',
                 # ^ use on local Windows development environment
                 Driver='PostgreSQL',
                 # ^ Use on shinyapps.io deployment
                 Server='3.239.228.42',
                 Port='5432',
                 Database='postgres',
                 Uid='postgres',
                 Pwd='&j>n!_nL]k&wWdE>*TVds4P6')

# options(shiny.reactlog = TRUE)

api_key <- "AIzaSyCBjR3FHdXlv8gCetNC5j1D507UzC6Y_dM"

polygonTypes <- c('State','County','Zip Code','City','Parcel')

zipCodeList <- fread('zipCodes.csv')[,1]

stateList <- c('CA','AZ')

countyList <- c('LA County','Orange County')

cityList <- fread('zipCodes.csv')[,2]
cityList <- cityList[City != ""]

freehand <- 'Please draw polygon on map'

ui <- dashboardPage(
  
  dashboardHeader(title = "CityAnalytics"),
  
  dashboardSidebar(width = 300,
                   collapsed = TRUE,
                   
                   hr(),
                   
                   HTML('<h4>&nbsp&nbspStep One, Define Polygon: </h4>'),
                   
                   selectInput('polygon',h5("Draw freehand polygon or select a preloaded polygon: "),
                               choices = list("Draw polygon on map" = 1, 
                                              "Predefined polygon" = 2),
                               selected = 2),
                   
                   pickerInput(
                     inputId = "polygonType",
                     label = h5("Select type of polygon: "),
                     choices = c(),
                     multiple = FALSE,
                     width = "100%"
                   ),
                   
                   pickerInput(
                     inputId = "specifyPolygon",
                     label = h5("Select pre loaded polygon: "),
                     choices = c(),
                     multiple = TRUE,
                     options = list(
                       `actions-box` = TRUE
                     ),
                     width = "100%"
                   ),
                   
                   hr(),
                   
                   HTML('<h4>&nbsp&nbspStep Two, Run the Model: </h4>'),
                   
                   div(style="display:inline-block;width:1%;text-align: center;",
                       actionButton("button", "Run the model", icon = icon('fa-brain')))
                   
  ),
  dashboardBody(
    
    shinyDashboardThemes(
      theme = "grey_light"
      #Available theme options:
      #'blue_gradient',
      #'flat_red',
      #'grey_light',
      #'grey_dark',
      #'onenote',
      #'poor_mans_flatly',
      #'purple_gradient'
      
    ),
    
    tags$style(".small-box.bg-navy { background-color: #1dd12d !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-teal { background-color: #086f69 !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-olive { background-color: #7c807c !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-lime { background-color: #2252ff !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-maroon { background-color: #D3D3D3 !important; color: #000000 !important; }"),
    
    tabsetPanel(
      
      tabPanel("About this Tool",
               
               HTML({
                 
                 AboutPage
                 
               })
               
      ),
      
      tabPanel("Select Polygon", 
               
               box(width = 8,
                   textInput("address", label = "Please type in a reference address: "),
                   value = '900 Wilshire Blvd, Los Angeles, CA 90017, United States'),
               
               box(width = 4,
                   actionButton("submitAddress", label = "Submit Address")),
               
               box(width = 12,
                   google_mapOutput(outputId = "myMap", height = 800)
               ),
               
               box(width = 12,
                   dataTableOutput("vbox"))
               
      ),
      
      tabPanel("Model Outputs", 
               
               h3('Model Outputs'),
               
               sliderInput("slider1", h3("Select year"),
                           min = 2010, max = 2020, value = 2020,
                           step = 2),
               
               column(
                 width = 12,
                 
                 valueBoxOutput("info_box1", width = 2),
                 
                 valueBoxOutput("info_box2", width = 2),
                 
                 valueBoxOutput("info_box3", width = 2),
                 
                 valueBoxOutput("info_box4", width = 2),
                 
                 valueBoxOutput("info_box5", width = 2)
                 
               ),
               
               column(
                 width = 10,
                 
                 plotlyOutput('testPlot'),  
                 
               ),
               
               column(
                 width = 12,
                 fluidRow(
                   
                   plotlyOutput('testPlot2'), 
                   
                 )),
               
               hr(),
               
      ),
      
      tabPanel("Hot to Use CityAnalytics", 
               
               tableOutput("table")
               
      )
    )
  )
) 

mapLocation <- reactiveValues(a=c('34.1','-118.2'))

################################################################################
####################### S E R V E R ############################################
################################################################################

server <- function(input, output, session) {
  
  observeEvent(input$polygon, {
    
    if (input$polygon == 2) {
      
      secondMenu <- polygonTypes
      
    } else if (input$polygon == 1) {
      
      secondMenu <- freehand
      
    } 
    
    updatePickerInput(
      session,
      inputId = "polygonType",
      choices = secondMenu
    )
    
  })
  
  observeEvent(input$polygonType, {
    
    if (input$polygonType == 'Zip Code') {
      
      thirdMenu <- zipCodeList
      
    } else if (input$polygonType == 'State') {
      
      thirdMenu <- stateList
      
    } else if (input$polygonType == 'County') {
      
      thirdMenu <- countyList
      
    } else if (input$polygonType == 'City') {
      
      thirdMenu <- cityList
      
    } else {
      
      thirdMenu <- 'Comming soon'
      
    } 
    
    updatePickerInput(
      session,
      inputId = "specifyPolygon",
      choices = thirdMenu
    )
    
  })
  
  output$myMap <- renderGoogle_map({
    
    observeEvent(input$submitAddress, {
      
      if (input$address == "" || input$address == "{}") {
        
        newAddress <- 'Los Angeles, CA'
        
      } else {
        
        newAddress <- input$address
        
      }
      
      polyCoordinates <- google_geocode(
        newAddress,
        bounds = NULL,
        key = api_key,
        language = NULL,
        region = NULL,
        components = NULL,
        simplify = TRUE,
        curl_proxy = NULL
      )
      
      polyCoordinates <- as.data.frame(polyCoordinates[['results']][[3]])
      
      polyCoordinates <- as.data.frame(polyCoordinates['location'])
      
      polyCoordinates <- c(polyCoordinates$location$lat,
                           polyCoordinates$location$lng)
      
      mapLocation$a <<- polyCoordinates
      
      if (input$polygon == 1) {
        
        output$myMap <- renderGoogle_map({
          google_map(location = mapLocation$a,
                     zoom = 18,
                     key = api_key,
                     event_return_type = "list"
                     
          ) %>%
            
            add_drawing(drawing_modes = c("polygon"),
                        delete_on_change = TRUE)
          
        })
        
      } else if (input$polygon == 2){
        
        output$myMap <- renderGoogle_map({
          google_map(location = mapLocation$a,
                     zoom = 18,
                     key = api_key,
                     event_return_type = "list")
        })
        
      }
      
    })
    
  })
  
  panelData <- reactive({
    
    #Query is parametrized to line and start and end date
    query <- as.character('SELECT * FROM \"public\".\"panel_zipcode\"')
    
    data <- dbGetQuery(con, query)
    
    tryCatch({
      
      if (!is.null(input$specifyPolygon)) {
        
        data <- subset(data, subset = zipcode %in% input$specifyPolygon)
        
      }
      
    }, error = function(e) {
      
      if (!is.null(input$specifyPolygon)) {
        
        data <- subset(data, subset = city %in% input$specifyPolygon)
        
      }
      
    })
    
  })
  
  output$testPlot <- renderPlotly({
    
    tryCatch({
      
      data <- panelData()
      
      data <- data %>%
        select(6:10,12)
      
      data <- aggregate(.~year, data = data, FUN=sum)
      
      data <- melt(setDT(data), id.vars = c("year"), variable.name = "areaType")
      
      data$value <- as.numeric(data$value)
      
      maxArea <- max(data$value)
      
      data$value <- data$value/maxArea
      
      data <-
        mutate(
          data,
          color = case_when(
            areaType == 'polygon_area' ~ '#D3D3D3',
            areaType == 'lawn_area' ~ '#1dd12d',
            areaType == 'tree_area' ~ '#086f69',
            areaType == 'impervious_area' ~ '#7c807c',
            areaType == 'water_area' ~ '#2252ff',
            areaType == 'soil_area' ~ '#A47041 '
            
          )
        )
      
      pointData <- subset(data, subset = year == input$slider1)
      
      if (input$slider1 == '2010') {Vvalue <- 1}
      else if (input$slider1 == '2012') {Vvalue <- 2}
      else if (input$slider1 == '2014') {Vvalue <- 3}
      else if (input$slider1 == '2016') {Vvalue <- 4}
      else if (input$slider1 == '2018') {Vvalue <- 5}
      else if (input$slider1 == '2020') {Vvalue <- 6}
      
      ggplot(data = data, aes(x=year,y=value)) +
        geom_line(aes(group = data$areaType), color = data$color, size =2)+
        geom_point(data = pointData, aes(x=year,y=value), 
                   alpha = 0.8, color = 'orange', size=3) +
        geom_rect(aes(xmin = Vvalue-.05, xmax = Vvalue+.05,
                      ymin = 0, ymax = 1), fill = 'orange', alpha = 0.2) +
        theme_bw() + 
        labs(title = "Land Coverage Area Evolution Period 2010:2020", 
             x = 'year', y = '% of total polygon area') +
        ylim(0,1)
      
    }, error = function(e) {
      
      ggplot()
      
    })
    
  })
  
  #Creates the query string by pasting together the request URL, and the 
  #User defined JSON polygon coordinates
  query <- reactive({
    
    FastAPIlink <- 'http://3.239.228.42:5000/predict_polygon'
    
    FastAPIobject <- (input$myMap_polygoncomplete)
    
    FastAPIobject=toJSON(FastAPIobject,pretty=TRUE,auto_unbox=TRUE)
    
    FastAPIobject <- as.character(FastAPIobject)
    
    request <- paste0(FastAPIlink,"/",FastAPIobject)
    
    request
    
  })
  
  #If request is null (user hasnt made request), do nothing, otherwise 
  #(with completed request), query the API and fetch response into a 
  #Data.Table object
  response <- reactive({
    
    if (is.null(input$myMap_polygoncomplete)) {

    } else {

      query <- URLencode(query())

      if (substr(query,1,4) == 'http') {

        btc <- jsonlite::fromJSON(query)

      }

      return(btc)

    }
    
  })
  
  #For now, we're not unpacking the response object, we are just printing it on 
  #screen to confirm succesful response. This function will be replaced with 
  #functionality to (a) unpack the response object, and (b)distribute response 
  #object accross application for insights and visualizations
  output$vbox <- renderDataTable({
    
    output <- as.data.frame(response())
    
    output
    
  })
  
  output$info_box1 <- renderValueBox({
    
    data <- panelData()
    
    if (is.null(data)) {
      
      (tags$p(NULL, 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Polygon Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "maroon", icon = icon("object-ungroup", color = 'white'))
      
    } else {
      
      data <- subset(data, subset = year == input$slider1)
      
      area <- sum(data$polygon_area)
      
      (tags$p(round(area,2), 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Polygon Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "maroon", icon = icon("object-ungroup", color = 'lolo'))
      
    }
    
  })
  
  output$info_box2 <- renderInfoBox({
    
    data <- panelData()
    
    if (is.null(data)) {
      
      (tags$p(NULL, 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Lawn Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "navy", icon = icon("futbol-o", color = 'white'))
      
    } else {
      
      data <- subset(data, subset = year == input$slider1)
      
      area <- sum(data$lawn_area)
      
      (tags$p(round(area,2), 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Lawn Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "navy", icon = icon("futbol-o", color = 'lolo'))
      
    }
    
  })
  
  output$info_box3 <- renderInfoBox({
    
    data <- panelData()
    
    if (is.null(data)) {
      
      (tags$p(NULL, 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Tree Coverage Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "teal", icon = icon("tree", color = 'white'))
      
    } else {
      
      data <- subset(data, subset = year == input$slider1)
      
      area <- sum(data$tree_area)
      
      (tags$p(round(area,2), 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Tree Coverage Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "teal", icon = icon("tree", color = 'lolo'))
      
    }
    
  })
  
  output$info_box4 <- renderInfoBox({
    
    data <- panelData()
    
    if (is.null(data)) {
      
      (tags$p(NULL, 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Impervious Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "olive", icon = icon("road", color = 'white'))
      
    } else {
      
      data <- subset(data, subset = year == input$slider1)
      
      area <- sum(data$impervious_area)
      
      (tags$p(round(area,2), 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Impervious Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "olive", icon = icon("road", color = 'lolo'))
      
    }
    
  })
  
  output$info_box5 <- renderInfoBox({
    
    data <- panelData()
    
    if (is.null(data)) {
      
      (tags$p(NULL, 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Water Body Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "lime", icon = icon("tint", color = 'white'))
      
    } else {
      
      data <- subset(data, subset = year == input$slider1)
      
      area <- sum(data$water_area)
      
      (tags$p(round(area,2), 
              style = "font-size: 100%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Water Body Area (kms^2)", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "lime", icon = icon("tint", color = 'lolo'))
      
    }
    
  })
  
  output$info_box6 <- renderInfoBox({
    
    infoBox("NDVI (min / median / max)", paste0("3 / 4 / 5"), icon = icon("leaf"))
    
  })
  
}


shinyApp(ui, server)