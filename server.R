library(shiny)
library(UsingR)
library(shinyapps)

# Function to plot the Standings based on the input "week"
plotStandings <<- function(week) {
        standings <- subset(Standings, Week == week)
        standings <- standings[order(standings$Cumulative, decreasing = TRUE),]
        standings <- standings[,c("Team", "Cumulative")]
        standings$fill <- c(rep("lightcyan",3), rep("lightblue",17))
        # print(standings)
        s20 <- ggplot(standings, aes(y = Cumulative, x = reorder(Team,Cumulative))) +
                geom_bar(stat='identity', fill = standings$fill) +
                # geom_bar(stat='identity') +
                # scale_fill_gradient(low="#FF8888",high="#FF0000") +
                xlab("") + ylab("Total Points") +
                ggtitle(paste("EPL Standings after Week",week)) +
                geom_text(aes(label=Cumulative), position=position_dodge(width=0.9), 
                          vjust=0.5, size = 3) +
                coord_flip()
        s20
}

# Create machine learning (Random Forests) algorithm 
pred <- Standings
# Additional column to show recent points performance over the previous 5 games
for (i in 1:nrow(pred)) {
        if (pred$Week[i] <=5) {
                r <- subset(pred[1:i,], Team == pred$Team[i])
                pred$Recent[i] <- mean(r$Points)
        }
        else {
                # subsetting only the games from the last 5 weeks for each team
                idx <- (pred$Week[i]-5)*20+1  
                r <- subset(pred[idx:i,], Team == pred$Team[i]) 
                pred$Recent[i] <- mean(r$Points)
                if (nrow(r) != 5) print(paste("Error:",i, r))
        }
}

rfModFit <- train(Points ~., data = pred, method = "rf", 
                  trControl = trainControl(method = "cv", number = 5), 
                  ntree = 100, warn = FALSE)


# Create home and away predictors based on input selections
predWin <<- function(week,HTeam,ATeam){
        Hsel <- subset(pred, (Week == week) & (Team == HTeam ))
        Hsel$Home <- "Home"
        Asel <- subset(pred, (Week == week) & (Team == ATeam ))
        Asel$Home <- "Away"
        
        Hpred <- predict(rfModFit, Hsel)
        Apred <- predict(rfModFit, Asel)
        print(paste(week,HTeam,Hpred,ATeam,Apred))
        
        Outcome <- ifelse(Hpred > Apred, paste("Home team wins -",HTeam), 
                          paste("Away team wins -",ATeam))
        if (abs(Hpred - Apred) < 0.2) Outcome <- "Match end in a draw"
        
        return(Outcome)
}

shinyServer(  
        function(input, output) {    
                
                # Output functions
                output$plotStandings <- renderPlot({ 
                        week <- input$week
                        output$week <- renderText(week)
                        plotStandings(week)
                })
                output$predHdr <- renderText({
                        input$goButton
                        isolate(paste("Match prediction for week ",input$week,":", sep = ""))
                })
                output$Outcome <- renderText({
                        input$goButton
                        isolate(predWin(input$week, input$Hsel,input$Asel))
                })
                }
)