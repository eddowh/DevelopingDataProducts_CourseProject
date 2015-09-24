library(shiny)
library(shinyGlobe)


shinyServer(
    
    function(input, output, session) {
        
        inj <- readRDS("./percent_injury.Rds")
        fat <- readRDS("./percent_fatality.Rds")
        prop <- readRDS("./percent_property_damage.Rds")
        crop <- readRDS("./percent_crop_damage.Rds")
        tot <- readRDS("./percent_total_damage.Rds")
        states <- as.character(fat$State)
        
        # Initialize reactive values
        values <- reactiveValues()
        values$states <- states
        
        output$states <- renderUI({
            checkboxGroupInput('states', 'States:',
                               states, selected = values$states, inline = TRUE)
        })
        
        # Add observer on select-all button
        observe({
            if(input$selectAll == 0) return()
            updateCheckboxGroupInput(session=session, inputId="states",
                                     choices = states,
                                     selected = c(states),
                                     inline = TRUE)
        })
        
        # Add observer on clear-all button
        observe({
            if(input$clearAll == 0) return()
            updateCheckboxGroupInput(session=session, inputId="states",
                                     choices = states,
                                     selected = c(),
                                     inline = TRUE)
        })
        
        # globe
        output$globe <- renderGlobe({
            
            if (is.null(input$select))
                return(NULL)
            
            if (input$select == "injury") {
                selectedStates <- data.frame()
                for (i in 1:length(input$states)) {
                    temp <- subset(inj, State == input$states[i])
                    selectedStates <- rbind(selectedStates, temp)
                }
                selectedStates[, -1]
            }
            
            else if (input$select == "fatality") {
                selectedStates <- data.frame()
                for (i in 1:length(input$states)) {
                    temp <- subset(fat, State == input$states[i])
                    selectedStates <- rbind(selectedStates, temp)
                }
                selectedStates[, -1]
            }
            
            else if (input$select == "prop") {
                selectedStates <- data.frame()
                for (i in 1:length(input$states)) {
                    temp <- subset(prop, State == input$states[i])
                    selectedStates <- rbind(selectedStates, temp)
                }
                selectedStates[, -1]
            }
            
            else if (input$select == "crop") {
                selectedStates <- data.frame()
                for (i in 1:length(input$states)) {
                    temp <- subset(crop, State == input$states[i])
                    selectedStates <- rbind(selectedStates, temp)
                }
                selectedStates[, -1]
            }
            
            else if (input$select == "tot") {
                selectedStates <- data.frame()
                for (i in 1:length(input$states)) {
                    temp <- subset(tot, State == input$states[i])
                    selectedStates <- rbind(selectedStates, temp)
                }
                selectedStates[, -1]
            }
        })
      
        
    }
    
)