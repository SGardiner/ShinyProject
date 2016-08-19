# Function to clean EPL datasets from www.rsssf.com
# http://www.rsssf.com/tablese/eng2015.html  # 2014-2015 season
# http://www.rsssf.com/tablese/eng2016.html  # 2015-2016 season
# 
# The input for the EPLclean function is the name of a dataset csv file 
# such as "eng2015.csv".  The input dataset is the game outcomes copy and pasted 
# from the www.rsssf.com site.  The function returns a dataframe called Results that
# contains the cleaned dataset.

# Examples:
# Results <- EPLclean("eng2015.csv")
# write.csv(EPLclean("eng2015.csv"), "EPL2015.csv", row.names=FALSE)

# Also, change working directory to "~/rprogramming/DevelopingDataProducts"
# setwd("~/rprogramming/DevelopingDataProducts/ShinyProject")

EPLclean <- function(inDataset) {
        # setwd("~/rprogramming/DevelopingDataProducts/ShinyProject")
        # print(inDataset)
        
        # initialize dataframe
        Results <- as.data.frame(matrix(nrow = 1, ncol = 6))
        colnames(Results) <- c("Week","Date", "Home", "Away", "HScore", "AScore")
        
        # read in all lines of the input dataset into a character vector
        all_data <- readLines(inDataset, warn = FALSE)
        
        # create function to trim leading and trailing spaces
        trim <- function (x) gsub("^\\s+|\\s+$", "", x) 
        
        count = 0
        
        # Index through all the data to extract the relevant fields
        for (i in 1:length(all_data)) {
                len <- nchar(all_data[i])
                # Search for strings for each "Round" and save as variable "week"
                if (grepl("Round", all_data[i])) {
                        week <- as.numeric(substr(all_data[i], len-1, len))
                        # print(all_data[i]); print(i); print(week)
                }
                # Save "[date]" strings as variable "date"
                else if (grepl("]", all_data[i])) {
                        date <- all_data[i]
                        # print(all_data[i]); print(i); print(date)
                }
                # Save Home and Away team names and scores and write output
                # to Results dataframe
                else if(all_data[i] != "") { 
                        d <- regexpr("-", all_data[i])[1]
                        HScore <- substr(all_data[i], d-1, d-1)
                        AScore <- substr(all_data[i], d+1, d+1)
                        Home <- trim(substr(all_data[i], 1, d-2))
                        Away <- trim(substr(all_data[i], d+2, len))
                        count = count + 1
                        Results[count,] <- c(week, date, Home, Away, HScore, AScore)
                }
        }
        # Add in points for wins (3 points) losses (0 points) and draws (1 point)
        for (i in 1:nrow(Results)) {
                if (Results$HScore[i] == Results$AScore[i]) {
                        Results$HPoints[i] <- 1
                        Results$APoints[i] <- 1
                }
                else if (Results$HScore[i] > Results$AScore[i]) {
                        Results$HPoints[i] <- 3
                        Results$APoints[i] <- 0
                }
                else {
                        Results$HPoints[i] <- 0
                        Results$APoints[i] <- 3  
                }
        }
        # Change columns with integers to the correct class
        Results$Week <- as.integer(Results$Week)
        Results$HScore <- as.integer(Results$HScore)
        Results$AScore <- as.integer(Results$AScore)
        Results$HPoints <- as.integer(Results$HPoints)
        Results$APoints <- as.integer(Results$APoints)
        
        # Correct spelling of shortened team names
        for (i in 1:nrow(Results)) {
                Results$Home[i] <- gsub("Crystal P", "Crystal Palace", Results$Home[i]) 
                Results$Away[i] <- gsub("Crystal P", "Crystal Palace", Results$Away[i]) 
                Results$Home[i] <- gsub("Manchester U", "Manchester United", Results$Home[i]) 
                Results$Away[i] <- gsub("Manchester U", "Manchester United", Results$Away[i])
                Results$Home[i] <- gsub("Manchester C", "Manchester City", Results$Home[i]) 
                Results$Away[i] <- gsub("Manchester C", "Manchester City", Results$Away[i])
        }

        # return the Results dataframe
        return(Results)
}

# Function to take the EPLclean output dataset and return data with one row per team
# per week, including whether they were the  Home or Away team, points scored 
# for that week's game and cumulative points for the season up to that week
# The inputs are the Results dataset from the CleanEPL function.  
# The function returns a dataframe called Standings.

# "EPL2015.csv".  
# The other input is the name of the csv file that the cleaned dataset is written
# to, such as "Standings2015.csv".
#
# Examples:
# Standings <- standings(Results)
# Standings <- standings(EPLclean("eng2015.csv"))
# Standings <- standings(read.csv("EPL2015.csv"))
# write.csv(standings(read.csv("EPL2015.csv")), "standings2015.csv",row.names=FALSE)

# Also, change working directory to "~/rprogramming/DevelopingDataProducts"
# setwd("~/rprogramming/DevelopingDataProducts/ShinyProject")

standings <- function(inDF) {
        # setwd("~/rprogramming/DevelopingDataProducts/ShinyProject")
        
        # Read input dataset
        Results <- inDF
        Results$Home <- as.character(Results$Home)
        Results$Away <- as.character(Results$Away)
        
        # Create another dataset with points standings
        Standings <- as.data.frame(matrix(ncol = 4))
        colnames(Standings) <- c("Week", "Team", "Points","Home")
        count = 1
        for (i in 1:nrow(Results)) {
                Standings[count,] <- c(Results$Week[i], Results$Home[i],
                                           Results$HPoints[i],"Home")
                Standings[count + 1,] <- c(Results$Week[i], Results$Away[i],
                                               Results$APoints[i],"Away")
                count <- count + 2
                # print(i); print(count)
        }
        Standings$Week <- as.integer(Standings$Week)
        Standings$Points <- as.numeric(Standings$Points)
        
        # Add column for cumulative point totals for previous weeks of play
        for (i in 1:nrow(Standings)) {
                weekly <- subset(Standings[c(1:i),],Team == Team[i])
                Standings$Cumulative[i] <- sum(weekly$Points)
        }
        Standings$Cumulative <- as.integer(Standings$Cumulative)
        
        # Return the Standings dataframe
        return(Standings)
}







