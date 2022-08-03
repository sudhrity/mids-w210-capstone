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
library(sandwich)
library(lmtest)
library(stringr)
library(shinyscreenshot)
source("about.R")

con <- dbConnect(odbc(),
                 # Driver='Devart ODBC Driver for PostgreSQL',
                 # ^ use on local Windows development environment
                 Driver='PostgreSQL',
                 # ^ Use on shinyapps.io deployment
                 Server='18.204.57.173',
                 Port='5432',
                 Database='postgres',
                 Uid='postgres',
                 Pwd='&j>n!_nL]k&wWdE>*TVds4P6')


features <- c('polygon_area','water_area','lawn_area','tree_area','pv_area',
              'impervious_area','soil_area','turf_area','tree_ndvi_mean',
              'tree_ndvi_max','tree_ndvi_min','grass_ndvi_mean','grass_ndvi_max',
              'grass_ndvi_min')

climateFeature <- c("lst_day_mean","lst_day_max","lst_day_min","lst_night_mean", 
                    "lst_night_max","lst_night_min")

options(shiny.reactlog = TRUE)

api_key <- "AIzaSyCBjR3FHdXlv8gCetNC5j1D507UzC6Y_dM"

polygonTypes <- c('State','County','Zip Code','City','Parcel')

zipCodeList <- fread('zipCodes.csv')[,1]

stateList <- c('CA','AZ')

countyList <- c('LA County','Orange County')

cityList <- fread('zipCodes.csv')[,2]
cityList <- cityList[City != ""]

freehand <- 'Please draw polygon on map'

estimatesData <- fread('Estimates.csv')

ui <- dashboardPage(
  
  dashboardHeader(title = "UrbanInsights"),
  
  dashboardSidebar(width = 0,
                   collapsed = TRUE
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
    
    # tags$head(tags$style(HTML('
    #                             /* body */
    #                             .content-wrapper, .right-side {
    #                             background-color: #FFFFFF;
    #                             }
    #                             
    #                             '))),
    
    tags$style(".small-box.bg-navy { background-color: #1dd12d !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-teal { background-color: #086f69 !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-olive { background-color: #7c807c !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-lime { background-color: #2252ff !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-maroon { background-color: #D3D3D3 !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-purple { background-color: #A47041 !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-fuchsia { background-color: #0b9ed5 !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-black { background-color: #282C7C !important; color: #000000 !important; }"),
    tags$style(".small-box.bg-orange { background-color: #FAA41A !important; color: #000000 !important; }"),
    
    tags$head(tags$style(
      HTML('.wrapper {height: auto !important; position:relative; overflow-x:hidden; overflow-y:hidden}')
    )),
    
    tabsetPanel(
      
      tabPanel("About this Tool",
               
               fluidRow(
                 
                 HTML({
                   
                   AboutPage
                   
                 })
                 
               ),
               
      ),
      
      tabPanel("Custom Polygon", 
               
               fluidRow(
                 
                 HTML("<h3>&nbsp&nbsp&nbsp&nbspCustom Polygon Land Coverage</h3>"),
                 
                 column(width = 12,
                        
                        box(width = 2,
                            
                            valueBoxOutput("info_box1b", width = 12),
                            hr(),
                            valueBoxOutput("info_box2b", width = 12),
                            hr(),
                            valueBoxOutput("info_box3b", width = 12),
                            hr(),
                            valueBoxOutput("info_box4b", width = 12),
                            hr(),
                            valueBoxOutput("info_box5b", width = 12),
                            hr(),
                            valueBoxOutput("info_box6b", width = 12),
                            hr(),
                            valueBoxOutput("info_box7b", width = 12),
                            
                        ),
                        
                        box(width = 2,
                            
                            valueBoxOutput("info_box2a", width = 12),
                            
                            box(width = 12,
                                
                                div(style="height: 78px;",
                                    numericInput("slider1a", h6("Change lawn area (+/- %)"),
                                                 min = -100, max = 500, value = 0,
                                                 step = 1)),
                            ),
                            
                            box(width = 12,
                                
                                div(style="height: 78px;",
                                    numericInput("slider2a", h6("Change tree area"),
                                                 min = -100, max = 200, value = 0,
                                                 step = 1)),
                            ),
                            
                            box(width = 12,
                                
                                div(style="height: 78px;",
                                    numericInput("slider3a", h6("Change impervious area"),
                                                 min = -100, max = 200, value = 0,
                                                 step = 1)),
                            ),
                            
                            box(width = 12,
                                
                                div(style="height: 78px;",
                                    numericInput("slider4a", h6("Change soil area"),
                                                 min = -100, max = 200, value = 0,
                                                 step = 1)),
                                
                            ),
                            
                            box(width = 12,
                                
                                div(style="height: 78px;",
                                    numericInput("slider5a", h6("Change water area"),
                                                 min = -100, max = 200, value = 0,
                                                 step = 1)),
                            ),
                            
                            box(width = 12,
                                
                                div(style="height: 78px;",
                                    numericInput("slider6a", h6("Change turf area"),
                                                 min = -100, max = 200, value = 0,
                                                 step = 1)),
                                
                                
                            ),
                            
                        ),
                        
                        box(width = 8,
                            
                            column(width = 6,
                                   textInput("address", label = HTML("<h5>Please type in a reference address or click on submit address to start:</h5> <h6>To draw polygon, after map displays, use the draw polygon tool located at the top right corner of the map.</h6>")),
                                   value = '900 Wilshire Blvd, Los Angeles, CA 90017, United States'),
                            
                            column(width = 2,
                                   actionButton("submitAddress", label = "Submit Address")),
                            
                            column(width = 2,
                                   
                                   selectInput('metric', h5("Select units for area"),
                                               choices = c('sq. meters','sq. kilometers'),
                                               selected = 'meters',
                                               multiple = FALSE),
                                   
                            ),
                            
                            column(width = 2,
                                   
                                   actionButton("go", "Take a screenshot")
                                   
                            ),
                            
                            box(width = 12,
                                
                                column(width = 12,
                                       google_mapOutput(outputId = "myMap", height = 720)
                                ),
                                
                                # column(width = 6,
                                #        plotOutput(outputId = "inferencePlot")
                                # ),
                                
                            ),
                        ),
                        
                 ),
                 
                 HTML("<h3>&nbsp&nbsp&nbsp&nbspWater & Microclimate Insights</h3>"),
                 
                 column(width = 12,
                        
                        box(width = 6,
                            
                            h3("Microclimate Impact Analysis"),
                            
                            hr(),
                        
                            column(width = 12,
                                   
                                   valueBoxOutput("MCinfoBox1", width = 6),
                                   valueBoxOutput("MCinfoBox2", width = 6),
                                   
                                   column(width = 12,
                                          
                                          selectInput('inferenceModel', h5("Select which model data to use for microclimate estimates:"),
                                                      choices = c('Random Forest Model','TensorFlow Model'),
                                                      selected = 'Random Forest Model',
                                                      multiple = FALSE),
                                          
                                   ),
                                   
                                   column(width = 6,
                                          
                                          htmlOutput("microClimateOutputs")
                                          
                                   ),
                                   
                                   column(width = 6,
                                          
                                          plotlyOutput('MCPlot')
                                          
                                   ),
                            ),
                            
                        ),
                        
                        box(width = 6,
                            
                            h3("Water Impact Analysis"),
                            
                            hr(),
                            
                            column(width = 12,
                                   
                                   valueBoxOutput("H2OinfoBox1", width = 6),
                                   valueBoxOutput("H2OinfoBox2", width = 6),
                                   
                                   column(width = 12,
                                          
                                          sliderInput("waterQuant", HTML("<h5>Adjust watering default value of 0.623 gallons of water per sq. foot <br>(change in % from default):</h5>"),
                                                      min = -100, max = 100, value = 0, step = 1)
                                          
                                   ),
                                   
                                   column(width = 6,
                                          
                                          htmlOutput("waterOutputs")
                                          
                                   ),
                                   
                                   column(width = 6,
                                          
                                          plotlyOutput('WaterPlot')
                                          
                                   ),
                            ), 
                            
                        ),
                 ),
                 
               ),
               
      ),
      
      tabPanel("Predefined Polygon", 
               
               fluidRow(
                 
                 HTML("<h3>&nbsp&nbsp&nbsp&nbspPredefined Polygon Panel Data Analysis</h3>"),
                 
                 column(width = 12,
                        
                        column(width = 2,
                               
                               pickerInput("specifyPolygon", h5("Select a zip code(s):"), 
                                           choices = zipCodeList, 
                                           options = list(`actions-box` = TRUE),
                                           multiple = T,
                                           selected = '90210'),
                               
                               
                               # selectInput("specifyPolygon", h5("Select a zip code(s):"),
                               #             choices = zipCodeList,
                               #             selected = '90210',
                               #             multiple = TRUE),
                               
                        ),
                        
                        column(width = 2,
                               
                               sliderInput("slider1", h5("Select year"),
                                           min = 2010, max = 2020, value = 2020,
                                           step = 2),
                               
                        ),
                        
                        column(width = 2,
                               
                               selectInput('metric2', h5("Select units for area"),
                                           choices = c('sq. meters','sq. kilometers'),
                                           selected = 'meters',
                                           multiple = FALSE),
                               
                        ),
                        
                        column(width = 2,
                               
                               actionButton("go2", "Take a screenshot")
                               
                        ),
                        
                 ),
                 
                 column(
                   width = 12,
                   
                   # valueBoxOutput("info_box1", width = 12),
                   valueBoxOutput("info_box2", width = 2),
                   valueBoxOutput("info_box3", width = 2),
                   valueBoxOutput("info_box4", width = 2),
                   valueBoxOutput("info_box5", width = 2),
                   valueBoxOutput("info_box6", width = 2),
                   valueBoxOutput("info_box7", width = 2)
                   
                 ),
                 
                 column(
                   width = 12,
                   
                   plotlyOutput('landCoveragePlot'),  
                   
                 ),
                 
                 tabsetPanel(
                   
                   # tabPanel("Basic Insights",
                   #          
                   # ),
                   
                   tabPanel("Advanced Insights (Regression Panel)",
                            
                            br(),
                            
                            column(
                              width = 12,
                              
                              column(6,
                                     
                                     plotlyOutput('affluencyCorrPlot', height = 500), 
                                     
                              ),
                              
                              column(6,
                                     
                                     plotlyOutput('climateCorrPlot', height = 500), 
                                     
                              ),
                              
                              column(1,
                                     
                                     selectInput("affluencyXAxis", h5("Select an x axis feature"),
                                                 choices = features,
                                                 selected = 'tree_area',
                                                 multiple = FALSE),
                              ),
                              
                              column(1,
                                     
                                     h6("Apply transformation to x axis?"),
                                     checkboxInput("affluencyXTransf", "Log", 
                                                   value = TRUE),
                                     
                              ),
                              
                              column(1,
                                     
                                     selectInput("affluencyYAxis", h5("Select an y axis feature"),
                                                 choices = 'median_hh_income',
                                                 selected = 'median_hh_income',
                                                 multiple = FALSE),
                              ),
                              
                              column(1,
                                     
                                     h6("Apply transformation to y axis?"),
                                     checkboxInput("affluencyYTransf", "Log", 
                                                   value = TRUE),
                                     
                              ),
                              
                              column(2,
                                     
                              ),
                              
                              column(1,
                                     
                                     selectInput("climateXAxis", h5("Select an x axis feature"),
                                                 choices = features,
                                                 selected = 'tree_area',
                                                 multiple = FALSE),
                                     
                              ),
                              
                              column(1,
                                     
                                     h6("Apply transformation to x axis?"),
                                     checkboxInput("climateXTransf", "Log", 
                                                   value = TRUE),
                                     
                              ),
                              
                              column(1,
                                     
                                     selectInput("climateYAxis", h5("Select an y axis feature"),
                                                 choices = climateFeature,
                                                 selected = 'lst_day_mean',
                                                 multiple = FALSE),
                                     
                              ),
                              
                              column(1,
                                     
                                     h6("Apply transformation to y axis?"),
                                     checkboxInput("climateYTransf", "Log", 
                                                   value = TRUE),
                                     
                              ),
                              
                              column(2,
                                     
                              ),
                              
                              column(12,
                                     
                                     column(6,
                                            
                                            verbatimTextOutput('affluencyRegression'),
                                            
                                     ),
                                     
                                     column(6,
                                            
                                            verbatimTextOutput('climateRegression'),
                                            
                                     ),
                              ),
                              
                              hr(),
                              hr(),
                              hr(),
                              
                            )
                            
                   )
                   
                   
                 ),
                 
               ),
               
      )
      
      # tabPanel("How to Use UrbanInsights", 
      #          
      # )
    )
  )
) 

mapLocation <- reactiveValues(a=c('34.1','-118.2'))

################################################################################
####################### S E R V E R ############################################
################################################################################

server <- function(input, output, session) {
  
  observeEvent(input$go, {
    
    screenshot(
      selector = "section.content",
      filename = paste0('UrbanInsightsCustomPoly',Sys.Date()),
      scale = 1,
      timer = 0,
      download = TRUE
    )
    
  })
  
  observeEvent(input$go2, {
    
    screenshot(
      selector = "section.content",
      filename = paste0('UrbanInsightsPanelAnalysis',Sys.Date()),
      scale = 1,
      timer = 0,
      download = TRUE
    )
    
  })
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {

    dbDisconnect(con)

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
      
      
      output$myMap <- renderGoogle_map({
        google_map(location = mapLocation$a,
                   zoom = 18,
                   key = api_key,
                   event_return_type = "list"
                   
        ) %>%
          
          add_drawing(drawing_modes = c("polygon"),
                      delete_on_change = TRUE)
        
      }) }) })
  
  panelData <- reactive({
    
    #Query is parametrized to line and start and end date
    query <- as.character('SELECT * FROM \"public\".\"panel_zipcode\"')
    
    data <- dbGetQuery(con, query)
    
    return(data)
    
  })
  
  output$landCoveragePlot <- renderPlotly({
    
    tryCatch({
      
      data <- panelData()
      
      data <- subset(data, subset = zipcode %in% input$specifyPolygon)
      
      data <- data %>%
        select(6:10,12:14)
      
      data <- aggregate(.~year, data = data, FUN=sum)
      
      data <- melt(setDT(data), id.vars = c("year"), variable.name = "areaType")
      
      data$value <- as.numeric(data$value)
      
      maxArea <- max(data$value)
      3
      data$value <- data$value/maxArea
      
      data <-
        mutate(
          data,
          color = case_when(
            areaType == 'polygon_area' ~ '#d3d3d3',
            areaType == 'lawn_area' ~ '#1dd12d',
            areaType == 'tree_area' ~ '#086f69',
            areaType == 'impervious_area' ~ '#7c807c',
            areaType == 'water_area' ~ '#2252ff',
            areaType == 'soil_area' ~ '#a47041',
            areaType == 'turf_area' ~ '#0b9ed5',
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
        geom_line(aes(group = data$areaType), color = 'gray', size = 4) +
        geom_line(aes(group = data$areaType), color = data$color, size =3) +
        geom_point(data = pointData, aes(x=year,y=value), 
                   alpha = 0.8, color = 'orange', size=3) +
        geom_rect(aes(xmin = Vvalue-.05, xmax = Vvalue+.05,
                      ymin = 0, ymax = 1), fill = 'orange', alpha = 0.2) +
        theme_bw() +
        theme(plot.background = element_rect(fill = "#F0F0F0")) +
        labs(title = "Land Coverage Area Evolution Period 2010:2020", 
             x = 'year', y = '% of total polygon area') +
        ylim(0,1) +
        scale_x_discrete(limits = c('2010','2012','2014','2016','2018','2020'), 
                         expand = c(0, 0))
      
    }, error = function(e) {
      
      ggplot() + 
        theme(plot.background = element_rect(fill = "#F0F0F0")) 
      
    })
    
  })
  
  affluencyPlotData <- reactive({
    
    data <- panelData()
    
    data <- subset(data, subset = year == input$slider1)
    
    data[,8:14] <- data[,8:14]/data$polygon_area
    
    queryC <- as.character('SELECT * FROM \"public\".\"median_income\"')
    
    climateData <- dbGetQuery(con, queryC)
    
    dependentVariable <- paste0('y',as.character(input$slider1))
    
    climateData <- climateData %>%
      select(zipcode,dependentVariable)
    
    names(climateData)[2] <- 'median_hh_income'
    
    climateData <- na.omit(climateData)
    
    data <- left_join(data,climateData, by='zipcode')
    
    rm(climateData)
    
    xAxis <- as.character(input$affluencyXAxis)
    
    data <- data %>%
      select(zipcode,xAxis,median_hh_income)
    
    return(data)
    
  })
  
  output$affluencyCorrPlot <- renderPlotly({
    
    tryCatch({
      
      data <- affluencyPlotData()
      
      xAxis <- as.character(input$affluencyXAxis)
      
      median_hh_income <- 'median_hh_income'
      zipcode <- 'zipcode'
      
      if (input$affluencyXTransf == TRUE) {
        
        data[[xAxis]] <- log(data[[xAxis]])
        
      }
      
      if (input$affluencyYTransf == TRUE) {
        
        data[[median_hh_income]] <- log(data[[median_hh_income]])
        
        yAxisLabel <- paste0("Log of Median Household Income (USD)")
        
      } else {
        
        yAxisLabel <- "Median Household Income (USD)"
        
      }
      
      pointColor <- 'gray'
      
      dataSub <- subset(data, subset = zipcode %in% input$specifyPolygon)
      
      ggplot(data = data, aes_string(x=xAxis,y=median_hh_income)) + 
        geom_point(size = .1, color = 'white') + 
        geom_smooth(method = 'lm') + 
        geom_point(data=data, size = 2, color = pointColor,
                   aes_string(x=xAxis,y=median_hh_income, value = zipcode)) +
        geom_point(data = dataSub, aes_string(x=xAxis,y=median_hh_income,
                                              color = zipcode),
                   size=4) +
        theme_bw() +
        theme(plot.background = element_rect(fill = "#F0F0F0")) +
        theme(legend.position='none') +
        labs(title = paste0(str_to_title(xAxis),' vs Median Household Income for Year ',
                            input$slider1),
             x = xAxis,
             y = yAxisLabel)
      
    }, error = function(e) {
      
      ggplot() + 
        theme(plot.background = element_rect(fill = "#F0F0F0")) 
      
    })
    
  })
  
  output$affluencyRegression <- renderPrint({
    
    tryCatch({
      
      data <- affluencyPlotData()
      
      xAxis <- as.character(input$affluencyXAxis)
      
      median_hh_income <- 'median_hh_income'
      
      if (input$affluencyXTransf == TRUE) {
        
        data <- subset(data, subset = xAxis > 1)
        
        data[[xAxis]] <- log(data[[xAxis]])
        
      }
      
      if (input$affluencyYTransf == TRUE) {
        
        data <- subset(data, subset = median_hh_income > 1)
        
        data[[median_hh_income]] <- log(data[[median_hh_income]])
        
      } 
      
      data <- data[rowSums(sapply(data[-ncol(data)], is.infinite)) == 0, ]
      
      data <- na.omit(data)
      
      modelFormula <- paste0(median_hh_income,"~",xAxis)
      
      model <- lm(as.formula(modelFormula), data = data)
      
      totalRobust <- coeftest(model, vcov = vcovHC(model, type = 'HC3'))
      
      cInterval <- coefci(model, vcov. = vcovHC(model, type = 'HC3'))
      
      print(totalRobust)
      
      print(cInterval)
      
    }, error = function(e) {
      
      print('No values to make regression with')
      
    })
    
  })
  
  climateCorrData <- reactive({
    
    data <- panelData()
    
    data <- subset(data, subset = year == input$slider1)
    
    data[,8:14] <- data[,8:14]/data$polygon_area
    
    queryD <- as.character('SELECT * FROM \"public\".\"panel_microclimate\"') 
    
    climateData <- dbGetQuery(con, queryD)
    
    climateData <- subset(climateData, subset = year == input$slider1)
    
    climateFeature <- input$climateYAxis
    
    climateData <- climateData %>%
      select(zipcode,climateFeature)
    
    names(climateData)[2] <- 'yAxis'
    
    climateData <- na.omit(climateData)
    
    data <- left_join(data,climateData, by='zipcode')
    
    rm(climateData)
    
    selectFeature <- as.character(input$climateXAxis)
    
    data <- data %>%
      select(zipcode,selectFeature,yAxis)
    
    return(data)
    
  })
  
  output$climateCorrPlot <- renderPlotly({
    
    tryCatch({
      
      data <- climateCorrData()
      
      climateFeature <- input$climateYAxis
      
      selectFeature <- as.character(input$climateXAxis)
      
      yAxis <- 'yAxis'
      zipcode <- 'zipcode'
      
      if (input$climateXTransf == TRUE) {
        
        data[[selectFeature]] <- log(data[[selectFeature]])
        
      }
      
      if (input$climateYTransf == TRUE) {
        
        data[[yAxis]] <- log(data[[yAxis]])
        
      }
      
      pointColor <- 'gray'
      
      dataSub <- subset(data, subset = zipcode %in% input$specifyPolygon)
      
      ggplot(data = data, aes_string(x=selectFeature,y=yAxis)) + 
        geom_point(size = .1, color = 'white') + 
        geom_smooth(method = 'lm') + 
        geom_point(data=data, size = 2, color = pointColor,
                   aes_string(x=selectFeature,y=yAxis, value = zipcode)) +
        geom_point(data = dataSub, aes_string(x=selectFeature,y=yAxis,
                                              color = zipcode),
                   size=4) +
        theme_bw() +
        theme(plot.background = element_rect(fill = "#F0F0F0")) +
        theme(legend.position='none') +
        labs(title = paste0(str_to_title(selectFeature),' vs ',
                            str_to_title(climateFeature),' for Year ',
                            input$slider1),
             x = selectFeature,
             y = climateFeature) 
      
    }, error = function(e) {
      
      ggplot() + 
        theme(plot.background = element_rect(fill = "#F0F0F0")) 
      
    })
    
  })
  
  output$climateRegression <- renderPrint({
    
    tryCatch({
      
      data <- climateCorrData()
      
      climateFeature <- input$climateYAxis
      
      selectFeature <- as.character(input$climateXAxis)
      
      names(data)[3] <- as.character(climateFeature)
      
      if (input$climateXTransf == TRUE) {
        
        data <- subset(data, subset = selectFeature > 1)
        
        data[[selectFeature]] <- log(data[[selectFeature]])
        
      }
      
      if (input$climateYTransf == TRUE) {
        
        data <- subset(data, subset = climateFeature > 1)
        
        data[[climateFeature]] <- log(data[[climateFeature]])
        
      } 
      
      data <- data[rowSums(sapply(data[-ncol(data)], is.infinite)) == 0, ]
      
      data <- na.omit(data)
      
      modelFormula <- paste0(climateFeature,"~",selectFeature)
      
      model <- lm(as.formula(modelFormula), data = data)
      
      totalRobust <- coeftest(model, vcov = vcovHC(model, type = 'HC3'))
      
      cInterval <- coefci(model, vcov. = vcovHC(model, type = 'HC3'))
      
      print(totalRobust)
      
      print(cInterval)
      
    }, error = function(e) {
      
      print('No values to make regression with')
      
    })
    
  })
  
  #Creates the query string by pasting together the request URL, and the 
  #User defined JSON polygon coordinates
  query <- reactive({
    
    FastAPIlink <- 'http://18.204.57.173:5000/predict_polygon'
    
    FastAPIobject <- (input$myMap_polygoncomplete)
    
    FastAPIobject=toJSON(FastAPIobject,pretty=TRUE,auto_unbox=TRUE)
    
    FastAPIobject <- gsub(substr(FastAPIobject,20,21),"Md",FastAPIobject)
    
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
  
  infoBoxData <- reactive({
    
    data <- panelData()
    
    data <- subset(data, subset = zipcode %in% input$specifyPolygon)
    
    return(data)
    
  })
  
  output$H2OinfoBox1 <- renderInfoBox({
    
    tryCatch({
      
      waterStart <- waterUsageInference()[[1]]
      
      if (waterStart==0) {
        
        (tags$p("Polygon selection", 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Please make a land conversion to get water usage estimates", 
                              style = "font-size: 100%; margin:0; padding: 0;"),
            color = "lime", icon = icon("toggle-left", color = 'yellow'))
        
      } else {
        
        (tags$p(paste0(round(waterStart,2)," Gal/Day"), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Irrigation water usage before conversion", 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "lime", icon = icon("toggle-left", color = 'yellow'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "lime", icon = icon("toggle-left", color = 'yellow'))
      
    })
    
  })
  
  output$H2OinfoBox2 <- renderInfoBox({
    
    tryCatch({
      
      waterStart <- waterUsageInference()[[1]]
      waterEnd <- waterUsageInference()[[2]]
      
      waterEnd <- waterStart - waterEnd 
      
      if (waterEnd == 0 & input$slider1a == 0) {
        
        print(paste0("A:",waterEnd))
        
        (tags$p("Land conversion", 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Please make a grass land conversion to get water saving estimates", 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "green", icon = icon("toggle-right", color = 'white'))
        
      } else {
        
        if (waterEnd > 0) {
          
          (tags$p(paste0(round(waterEnd,2)," Gal/Day"), 
                  style = "font-size: 100%;  font-weight: bold;")) %>%
            valueBox(
              subtitle = tags$p("Water savings after conversion", 
                                style = "font-size: 120%; margin:0; padding: 0;"),
              color = "green", icon = icon("toggle-right", color = 'white'))
          
          
        } else if (waterEnd < 0) {
          
          (tags$p(paste0(round(abs(waterEnd),2)," Gal/Day"), 
                  style = "font-size: 100%;  font-weight: bold;")) %>%
            valueBox(
              subtitle = tags$p("Increased water consumption after conversion", 
                                style = "font-size: 120%; margin:0; padding: 0;"),
              color = "red", icon = icon("toggle-right", color = 'white'))
        }
        
      }
      
    }, error = function(e) {
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "green", icon = icon("toggle-right", color = 'white'))
      
    })
    
  })
  
  output$MCinfoBox1 <- renderInfoBox({
    
    tryCatch({
      
      ytotalDay <- microClimateInference()[[1]]
      ytotalNight <- microClimateInference()[[4]]
      
      if (is.nan(ytotalDay)) {
        
        (tags$p('Land conversion', 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Please make a land conversion to get microclimate estimates", 
                              style = "font-size: 100%; margin:0; padding: 0;"),
            color = "orange", icon = icon("sun", color = 'yellow'))
        
      } else {
        
        (tags$p(paste0(round(ytotalDay,2),"° C"), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Degrees Celsius daytime temperature change", 
                              style = "font-size: 100%; margin:0; padding: 0;"),
            color = "orange", icon = icon("sun", color = 'yellow'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "orange", icon = icon("sun", color = 'yellow'))
      
    })
    
  })
  
  output$MCinfoBox2 <- renderInfoBox({
    
    tryCatch({
      
      ytotalDay <- microClimateInference()[[1]]
      ytotalNight <- microClimateInference()[[4]]
      
      if (is.nan(ytotalDay)) {
        
        (tags$p('Land conversion', 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Please make a land conversion to get micrclimate estimates", 
                              style = "font-size: 100%; margin:0; padding: 0;"),
            color = "black", icon = icon("moon", color = 'white'))
        
      } else {
        
        (tags$p(paste0(round(ytotalNight,2),"° C"), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Degrees Celsius night-time temperature change", 
                              style = "font-size: 100%; margin:0; padding: 0;"),
            color = "black", icon = icon("moon", color = 'white'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "black", icon = icon("moon", color = 'white'))
      
    })
    
  })
  
  output$info_box2 <- renderInfoBox({
    
    tryCatch({
      
      data <- infoBoxData()
      
      if(input$metric2 == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Grass ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "navy", icon = icon("pagelines", color = 'white'))
        
      } else {
        
        data <- subset(data, subset = year == input$slider1)
        
        area <- (sum(data$lawn_area))/multiplier
        
        (tags$p(round(area,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Grass ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "navy", icon = icon("pagelines", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "navy", icon = icon("pagelines", color = 'white'))
      
    })
    
  })
  
  output$info_box3 <- renderInfoBox({
    
    tryCatch({
      
      data <- infoBoxData()
      
      if(input$metric2 == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- infoBoxData()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Tree ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "teal", icon = icon("tree", color = 'white'))
        
      } else {
        
        data <- subset(data, subset = year == input$slider1)
        
        area <- (sum(data$tree_area))/multiplier
        
        (tags$p(round(area,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Tree ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "teal", icon = icon("tree", color = 'lolo'))
        
      }
      
    }, error = function(e){
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "teal", icon = icon("tree", color = 'white'))
      
    })
    
  })
  
  output$info_box4 <- renderInfoBox({
    
    tryCatch({
      
      data <- infoBoxData()
      
      if(input$metric2 == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- infoBoxData()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Impervious ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "olive", icon = icon("road", color = 'white'))
        
      } else {
        
        data <- subset(data, subset = year == input$slider1)
        
        area <- (sum(data$impervious_area))/multiplier
        
        (tags$p(round(area,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Impervious ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "olive", icon = icon("road", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "olive", icon = icon("road", color = 'white'))
      
    })
    
  })
  
  output$info_box5 <- renderInfoBox({
    
    tryCatch({
      
      data <- infoBoxData()
      
      if(input$metric2 == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- infoBoxData()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tagstags$p(paste0("Water ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "lime", icon = icon("tint", color = 'white'))
        
      } else {
        
        data <- subset(data, subset = year == input$slider1)
        
        area <- (sum(data$water_area))/multiplier
        
        (tags$p(round(area,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Water ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "lime", icon = icon("tint", color = 'lolo'))
        
      }
      
    }, error = function(e){
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "lime", icon = icon("tint", color = 'white'))
      
    })
    
  })
  
  output$info_box6 <- renderInfoBox({
    
    tryCatch({
      
      data <- infoBoxData()
      
      if(input$metric2 == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- infoBoxData()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Soil ",units),  
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "purple", icon = icon("align-center", color = 'white'))
        
      } else {
        
        data <- subset(data, subset = year == input$slider1)
        
        area <- (sum(data$soil_area))/multiplier
        
        (tags$p(round(area,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Soil ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "purple", icon = icon("align-center", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "purple", icon = icon("align-center", color = 'white'))
      
    })
    
  })
  
  output$info_box7 <- renderInfoBox({
    
    tryCatch({
      
      data <- infoBoxData()
      
      if(input$metric2 == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- infoBoxData()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Turf ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "fuchsia", icon = icon("futbol-o", color = 'white'))
        
      } else {
        
        data <- subset(data, subset = year == input$slider1)
        
        area <- (sum(data$turf_area))/multiplier
        
        (tags$p(round(area,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Turf ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "fuchsia", icon = icon("futbol-o", color = 'white'))
        
      }
      
    }, error = function(e){
      
      (tags$p("Please try again", 
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "fuchsia", icon = icon("futbol-o", color = 'white'))
      
    })
    
  })
  
  
  ##########################################################################
  
  customPolygonAreas <- reactive({
    
    data <- as.data.frame(response())
    
    polygon_area <- (sum(data$polygon_area))
    
    ###LAWNS
    
    lawn_area <- (sum(data$grass_area))
    
    if (input$slider1a < -100) {
      
      lawnRate <- -100
      
    } else { lawnRate <- input$slider1a}
    
    lawn_areaB <- (lawn_area * (1 + (lawnRate/100)))
    
    ###TREES
    
    tree_area <- (sum(data$tree_area))
    
    if (input$slider2a < -100) {
      
      treeRate <- -100
      
    } else { treeRate <- input$slider2a}
    
    tree_areaB <- (tree_area * (1 + (treeRate/100)))
    
    ###IMPERVIOUS
    
    impervious_area <- (sum(data$impervious_area))
    
    if (input$slider3a < -100) {
      
      imperviousRate <- -100
      
    } else { imperviousRate <- input$slider3a}
    
    impervious_areaB <- (impervious_area * (1 + (imperviousRate/100)))
    
    ###SOIL
    
    soil_area <- (sum(data$soil_area))
    
    if (input$slider4a < -100) {
      
      soilRate <- -100
      
    } else { soilRate <- input$slider4a}
    
    soil_areaB <- (soil_area * (1 + (soilRate/100)))
    
    ###WATER
    
    water_area <- (sum(data$water_area))
    
    if (input$slider5a < -100) {
      
      waterRate <- -100
      
    } else { waterRate <- input$slider5a}
    
    
    water_areaB <- (water_area * (1 + (waterRate/100)))
    
    ###TURF
    
    turf_area <- (sum(data$turf_area))
    
    if (input$slider6a < -100) {
      
      turfRate <- -100
      
    } else { turfRate <- input$slider6a}
    
    turf_areaB <- (turf_area * (1 + (turfRate/100)))
    
    ###END
    
    areaRatio <- (lawn_areaB+tree_areaB+impervious_areaB+soil_areaB+
                    water_areaB+turf_areaB) / polygon_area
    
    areaList <- list(polygon_area,lawn_area,lawn_areaB,tree_area,tree_areaB,
                     impervious_area,impervious_areaB,soil_area,soil_areaB,
                     water_area,water_areaB,turf_area,turf_areaB,areaRatio)
    
    return(areaList)
    
  })
  
  waterUsageInference <- reactive({
    
    data <- customPolygonAreas()
       
    waterUsage <- 0.623
    
    waterUsage <- (waterUsage*(input$waterQuant/100))+waterUsage
    
    grassAreaStart <- data[[2]] * 10.7639
    startUsage <- waterUsage * grassAreaStart
    
    grassAreaEnd <- data[[3]] * 10.7639
    endUsage <- waterUsage * grassAreaEnd
    
    waterStats <- list(startUsage, endUsage)
    
    return(waterStats)
    
  })
  
  microClimateInference <- reactive({
    
    data <- customPolygonAreas()
    
    polygonArea <- data[[1]]
    
    grassAreaStart <- data[[2]]/polygonArea
    treeAreaStart <- data[[4]]/polygonArea
    waterAreaStart <- data[[10]]/polygonArea
    soilAreaStart <- data[[8]]/polygonArea
    turfAreaStart <- data[[12]]/polygonArea
    
    areastart <- data.frame(grass=grassAreaStart,tree=treeAreaStart,
                            water=waterAreaStart,soil=soilAreaStart,
                            turf=turfAreaStart)
    
    grassAreaEnd <- data[[3]]/polygonArea
    treeAreaEnd <- data[[5]]/polygonArea
    waterAreaEnd <- data[[11]]/polygonArea
    soilAreaEnd <- data[[9]]/polygonArea
    turfAreaEnd <- data[[13]]/polygonArea
    
    areaEnd <- data.frame(grass=grassAreaEnd,tree=treeAreaEnd,
                          water=waterAreaEnd,soil=soilAreaEnd,
                          turf=turfAreaEnd)
    
    if (input$inferenceModel == 'Random Forest Model') {
      
      model1 <- 'RFDay'
      model2 <- 'RFNight'
      
    } else if (input$inferenceModel == 'TensorFlow Model') {
      
      model1 <- 'TFDay'
      model2 <- 'TFNight'
      
    }
    
    usedModel <- subset(estimatesData, subset = model == model1)
    
    y1Day = areastart$grass*usedModel$grassEstimate + 
      areastart$tree * usedModel$treeEstimate +
      areastart$water * usedModel$waterEstimate +
      areastart$soil * usedModel$soilEstimate +
      areastart$turf * usedModel$turfEstimate
    
    y2Day = areaEnd$grass*usedModel$grassEstimate + 
      areaEnd$tree * usedModel$treeEstimate +
      areaEnd$water * usedModel$waterEstimate +
      areaEnd$soil * usedModel$soilEstimate +
      areaEnd$turf * usedModel$turfEstimate
    
    ytotalDay <- y2Day-y1Day
    
    y1MaxDay = areastart$grass*usedModel$grassMax + 
      areastart$tree * usedModel$treeMax +
      areastart$water * usedModel$waterMax +
      areastart$soil * usedModel$soilMax +
      areastart$turf * usedModel$turfMax
    
    y2MaxDay = areaEnd$grass*usedModel$grassMax + 
      areaEnd$tree * usedModel$treeMax +
      areaEnd$water * usedModel$waterMax +
      areaEnd$soil * usedModel$soilMax +
      areaEnd$turf * usedModel$turfMax
    
    ytotalMaxDay <- y2MaxDay-y1MaxDay
    
    y1MinDay = areastart$grass*usedModel$grassMin + 
      areastart$tree * usedModel$treeMin +
      areastart$water * usedModel$waterMin +
      areastart$soil * usedModel$soilMin +
      areastart$turf * usedModel$turfMin
    
    y2MinDay = areaEnd$grass*usedModel$grassMin + 
      areaEnd$tree * usedModel$treeMin +
      areaEnd$water * usedModel$waterMin +
      areaEnd$soil * usedModel$soilMin +
      areaEnd$turf * usedModel$turfMin
    
    ytotalMinDay <- y2MinDay-y1MinDay
    
    usedModelB <- subset(estimatesData, subset = model == model2)
    
    y1Night = areastart$grass*usedModelB$grassEstimate + 
      areastart$tree * usedModelB$treeEstimate +
      areastart$water * usedModelB$waterEstimate +
      areastart$soil * usedModelB$soilEstimate +
      areastart$turf * usedModelB$turfEstimate
    
    y2Night = areaEnd$grass*usedModelB$grassEstimate + 
      areaEnd$tree * usedModelB$treeEstimate +
      areaEnd$water * usedModelB$waterEstimate +
      areaEnd$soil * usedModelB$soilEstimate +
      areaEnd$turf * usedModelB$turfEstimate
    
    ytotalNight <- y2Night-y1Night
    
    y1MaxNight = areastart$grass*usedModelB$grassMax + 
      areastart$tree * usedModelB$treeMax +
      areastart$water * usedModelB$waterMax +
      areastart$soil * usedModelB$soilMax +
      areastart$turf * usedModelB$turfMax
    
    y2MaxNight = areaEnd$grass*usedModelB$grassMax + 
      areaEnd$tree * usedModelB$treeMax +
      areaEnd$water * usedModelB$waterMax +
      areaEnd$soil * usedModelB$soilMax +
      areaEnd$turf * usedModelB$turfMax
    
    ytotalMaxNight <- y2MaxNight-y1MaxNight
    
    y1MinNight = areastart$grass*usedModelB$grassMin + 
      areastart$tree * usedModelB$treeMin +
      areastart$water * usedModelB$waterMin +
      areastart$soil * usedModelB$soilMin +
      areastart$turf * usedModelB$turfMin
    
    y2MinNight = areaEnd$grass*usedModelB$grassMin + 
      areaEnd$tree * usedModelB$treeMin +
      areaEnd$water * usedModelB$waterMin +
      areaEnd$soil * usedModelB$soilMin +
      areaEnd$turf * usedModelB$turfMin
    
    ytotalMinNight <- y2MinNight-y1MinNight
    
    inferenceList <- list(ytotalDay,ytotalMaxDay,ytotalMinDay,
                          ytotalNight,ytotalMaxNight,ytotalMinNight)
    
    return(inferenceList)
    
  })
  
  output$MCPlot <- renderPlotly({
    
    tryCatch({
      
      ytotalDay <- microClimateInference()[[1]]
      ytotalMaxDay <- microClimateInference()[[2]]
      ytotalMinDay <- microClimateInference()[[3]]
      ytotalNight <- microClimateInference()[[4]]
      ytotalMaxNight <- microClimateInference()[[5]]
      ytotalMinNight <- microClimateInference()[[6]]
      
      MCPlotDF <- data.frame('label'=NA,'value'=NA)
      
      row1 <- c('DayTempDelta',ytotalDay)
      row2 <- c('DayTempDelta',ytotalMaxDay)
      row3 <- c('DayTempDelta',ytotalMinDay)
      row4 <- c('NightTempDelta',ytotalNight)
      row5 <- c('NightTempDelta',ytotalMaxNight)
      row6 <- c('NightTempDelta',ytotalMinNight)
      
      MCPlotDF <- rbind(MCPlotDF,row1)
      MCPlotDF <- rbind(MCPlotDF,row2)
      MCPlotDF <- rbind(MCPlotDF,row3)
      MCPlotDF <- rbind(MCPlotDF,row4)
      MCPlotDF <- rbind(MCPlotDF,row5)
      MCPlotDF <- rbind(MCPlotDF,row6)
      
      MCPlotDF$label <- as.factor(MCPlotDF$label)
      
      MCPlotDF <- na.omit(MCPlotDF)
      
      if (ytotalDay != 0) {
        
        MCPlotDF[,2] <- as.numeric(MCPlotDF[,2])
        
      }
      
      ggplot(data = MCPlotDF, aes(x=label,y=value, color = label, fill = label)) + 
        geom_boxplot(alpha = 0.3) + 
        scale_color_manual(values=c("#FAA41A","#282C7C")) +
        scale_fill_manual(values=c("#FAA41A","#282C7C")) +
        theme_bw() +
        labs(title = "Microclimate Impact",
             x="",
             y="Impact in Delta Degrees Celsius")+
        theme(plot.background = element_rect(fill = "#F8F8F8")) +
        theme(legend.position="none")
      
    }, error = function(e) {
      
      ggplot()
      
    })
    
  })
  
  output$microClimateOutputs <- renderUI({
    
    ytotalDay <- microClimateInference()[[1]]
    ytotalMaxDay <- microClimateInference()[[2]]
    ytotalMinDay <- microClimateInference()[[3]]
    ytotalNight <- microClimateInference()[[4]]
    ytotalMaxNight <- microClimateInference()[[5]]
    ytotalMinNight <- microClimateInference()[[6]]
    
    str2 <- paste("Daytime average temperature effect<br> (in degrees Celsius)")
    str3 <- paste0(paste0("5%: ", round(ytotalMinDay,2),
                          "° C       |      Estimate: ",round(ytotalDay,2),
                          "° C       |      95%: ", round(ytotalMaxDay,2),"° C"))
    str4 <- paste("Night-time average temperature effect<br> (in degrees Celsius)")
    str5 <- paste0(paste0("5%: ", round(ytotalMinNight,2), 
                          "° C       |      Estimate: ",round(ytotalNight,2), 
                          "° C       |      95%: ", round(ytotalMaxNight,2),"° C"))
    
    HTML(paste("<h4>",str2,"</h4>",
               "<h5>",str3,"<h5>",
               "<br>",
               "<h4>",str4,"</h4>",
               "<h5>",str5,"</h5>"
    ))
    
  })
  
  output$info_box1b <- renderInfoBox({
    
    tryCatch({
      
      data <- customPolygonAreas()
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Polygon ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "maroon", icon = icon("object-ungroup", color = 'white'))
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[1]]/multiplier
        
        (tags$p(round(area,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Polygon ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "maroon", icon = icon("object-ungroup", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("0",
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "maroon", icon = icon("object-ungroup"))
      
    })
    
  })
  
  output$info_box2b <- renderInfoBox({
    
    tryCatch({
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- customPolygonAreas()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Grass ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "navy", icon = icon("pagelines", color = 'white'))
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[2]]/multiplier
        finalArea <- data[[3]]/multiplier
        
        (tags$p(round(finalArea,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Grass ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "navy", icon = icon("pagelines", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("0",
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "navy", icon = icon("pagelines"))
      
    })
    
  })
  
  output$info_box3b <- renderInfoBox({
    
    tryCatch({
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- customPolygonAreas()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Tree ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "teal", icon = icon("tree", color = 'white'))
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[4]]/multiplier
        finalArea <- data[[5]]/multiplier
        
        (tags$p(round(finalArea,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Tree ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "teal", icon = icon("tree", color = 'lolo'))
        
      }
      
    }, error = function(e){
      
      (tags$p("0",
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "teal", icon = icon("tree"))
      
    })
    
  })
  
  output$info_box4b <- renderInfoBox({
    
    tryCatch({
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- customPolygonAreas()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Impervious ",units),  
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "olive", icon = icon("road", color = 'white'))
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[6]]/multiplier
        finalArea <- data[[7]]/multiplier
        
        (tags$p(round(finalArea,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Impervious ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "olive", icon = icon("road", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("0",
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "olive", icon = icon("road"))
      
    })
    
  })
  
  output$info_box5b <- renderInfoBox({
    
    tryCatch({
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- customPolygonAreas()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Soil ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "purple", icon = icon("align-center", color = 'white'))
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[8]]/multiplier
        finalArea <- data[[9]]/multiplier
        
        (tags$p(round(finalArea,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Soil ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "purple", icon = icon("align-center", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("0",
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "purple", icon = icon("align-center"))
      
    })
    
  })
  
  output$info_box6b <- renderInfoBox({
    
    tryCatch({
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- customPolygonAreas()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Water ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "lime", icon = icon("tint", color = 'white'))
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[10]]/multiplier
        finalArea <- data[[11]]/multiplier
        
        (tags$p(round(finalArea,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Water ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "lime", icon = icon("tint", color = 'lolo'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("0",
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "lime", icon = icon("tint"))
      
    })
    
  })
  
  output$info_box7b <- renderInfoBox({
    
    tryCatch({
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- customPolygonAreas()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Turf ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "fuchsia", icon = icon("futbol-o", color = 'white'))
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[12]]/multiplier
        finalArea <- data[[13]]/multiplier
        
        (tags$p(round(finalArea,2), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p(paste0("Turf ",units), 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "fuchsia", icon = icon("futbol-o", color = 'white'))
        
      }
      
    }, error = function(e) {
      
      (tags$p("0",
              style = "font-size: 80%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("Please complete your input or try again.", 
                            style = "font-size: 100%; margin:0; padding: 0;"),
          color = "fuchsia", icon = icon("futbol-o", color = 'white'))
      
    })
    
  })
  
  output$info_box2a <- renderInfoBox({
    
    tryCatch({
      
      if(input$metric == 'sq. meters') {
        
        multiplier <- 1
        units <- '(sq. meters)'
        
      } else { 
        
        multiplier <- 1000000
        units <- '(sq. kms)'
        
      }
      
      data <- customPolygonAreas()
      
      if (is.null(data)) {
        
        (tags$p(NULL, 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Total transformed area", 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = "black")
        
      } else {
        
        data <- customPolygonAreas()
        
        area <- data[[14]]
        
        area <- round(area*100,0)
        
        if (area == 100) {
          
          boxColor <- 'black'
          
        } else {
          
          boxColor <- 'red'
          
        }
        
        (tags$p(paste0(area,'%'), 
                style = "font-size: 100%;  font-weight: bold;")) %>%
          valueBox(
            subtitle = tags$p("Total transformed area", 
                              style = "font-size: 120%; margin:0; padding: 0;"),
            color = as.character(boxColor))
        
      }
      
    }, error = function(e) {
      
      (tags$p("Draw a polygon", 
              style = "font-size: 50%;  font-weight: bold;")) %>%
        valueBox(
          subtitle = tags$p("To start, type in a reference address in Los Anegeles Country or just click on submit address to start:", 
                            style = "font-size: 90%; margin:0; padding: 0;"),
          color = "black")
      
    })
    
  })
  
}


shinyApp(ui, server)