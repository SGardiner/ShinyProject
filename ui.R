library(shiny)
library(ggplot2)
library(caret)
library(dplyr)
library(randomForest)

# Read in the standings dataset
print("Reading Standings")
Standings <<- read.csv("standings2016.csv")
Standings$Team <<- as.character(Standings$Team)
Standings$Home <<- as.character(Standings$Home)

# UI code
shinyUI(pageWithSidebar(  
        headerPanel("English Premier League 2015-2016 Weekly Standings"),  
        sidebarPanel(    
                sliderInput('week', 'Pick a week to see the league standings',
                            value = 38, min = 1, max = 38, 
                            step = 1, ticks = FALSE, animate=TRUE),
                h4("Choose teams for a match prediction"),
                selectInput("Hsel", h5("Home Team"), unique(Standings$Team)),
                selectInput("Asel", h5("Away Team"), unique(Standings$Team),
                            selected = "Chelsea"),
                actionButton("goButton", "Submit"),
                h4(textOutput("predHdr")),
                textOutput("Outcome")
                ), 
        mainPanel(    
                plotOutput('plotStandings'),  
                p("The bar plot above shows the EPL Standings for each week of
                  the 2015-2016 season - the historic season that 
                  Leicester City won!  You can pick a different week of the
                  season using the slider and the plot will automatically update 
                  to show the league standings for that period.  The lowest three
                  teams, shown in light blue, are in the relegation zone to be 
                  demoted to the lower league."),
                p("In the sidebar, you can choose Home and Away teams using the drop
                  down boxes, and click Submit to make a prediction of the outcome
                  of a game between the two teams for the chosen week.  The prediction
                  is based on a machine learning algorithm using the results of
                  the season and recent game performance.  Have fun!"),
                p("GitHub repo for this project is at https://github.com/SGardiner/ShinyProject")
        )
))