library(shiny)
library(shinyGlobe)

inj <- readRDS("./percent_injury.Rds")
fat <- readRDS("./percent_fatality.Rds")
states <- as.character(fat$State)

shinyUI(fluidPage(
    
    includeCSS('./custom.css'),
    
    titlePanel("U.S. Nationwide Percentage of Storm Destruction (1996-2011)"),
    
    tagList(
        
        sidebarPanel(
            radioButtons(inputId = "select", 
                         label = "Choose:", 
                         choices = list("Injuries" = "injury",
                                        "Fatalities" = "fatality",
                                        "Property Damage" = "prop",
                                        "Crop Damage" = "crop",
                                        "Total Damage" = "tot"),
                         selected = "injury"),
            uiOutput('states'),
            # submitButton("Update!")
            actionButton(inputId = "clearAll", 
                         label = "Clear selection", 
                         icon = icon("square-o")),
            actionButton(inputId = "selectAll", 
                         label = "Select all", 
                         icon = icon("check-square-o"))

            ),
        
        mainPanel(
            globeOutput("globe"),
            div(id="info",
                tagList(
                    includeHTML('help.html'))
                )
            )
        
            )
    ))