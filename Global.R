library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(dplyr)
library(plotly)
library(leaflet)
library(readr)
library(stringr)
library(ggthemes)
library(scales)
library(tidyr)

### DataFrames Uploads and edits 
WorldCupMatches <- read.csv('WorldCupMatches.csv')
WorldCupMatches = within(WorldCupMatches,{ Score = paste(WorldCupMatches$Home.Team.Goals, WorldCupMatches$Away.Team.Goals, sep = ' - ', collapse=NULL) })
WorldCupPlayers <- read.csv('WorldCupPlayers.csv', sep = ",")
WorldCupPlayers <- WorldCupPlayers %>% mutate(Goals= str_count(WorldCupPlayers$Event,"'")) 
WorldCups <- read.csv('WorldCups.csv', sep = ";")
countryData <- read_delim("~/Downloads/country.csv", delim = "\t", escape_double = FALSE, trim_ws = TRUE)
countryData <- rename(countryData, Country = Name) ## to rename the Name column
countryData['Country'][countryData['Country'] == 'United States of America'] <- 'USA'
countryData['Country'][countryData['Country'] == 'United Kingdom'] <- 'England'
df <- inner_join(WorldCups, countryData, by = "Country")
ScorePre <- read.csv("Scores Prediction.csv", sep = ";")

## Declaring the max and min Year for the range 
YearMax <- max(WorldCupMatches$Year, na.rm = TRUE)
YearMin <- min(WorldCupMatches$Year, na.rm = TRUE)



