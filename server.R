# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  #Dashboard Cards 
  output$GoalsCard <- renderValueBox({
    valueBox(
      formatC(sum(WorldCups$GoalsScored), format="d", big.mark=','),
      paste('Total of goals:', sum(WorldCups$GoalsScored)),
      icon = icon("futbol",lib = 'font-awesome'),
      color = "green")
  })
  
  output$PlayerCard <- renderValueBox({
    valueBox(
      #test<- WorldCupPlayers %>%group_by(Player.Name) %>% summarise(goal_total = sum(Goals)) %>% arrange(goal_total) %>% tail(1),
      formatC(sum(WorldCupPlayers$Goals), format="d", big.mark=','),
      paste('Best Player: ', test$Player.Name),
      icon = icon("user",lib = 'font-awesome'),
      color = "red")
  })
  
  output$AttendanceCard <- renderValueBox({
    valueBox(
      formatC(sum(as.numeric(WorldCups$Attendance)), format="d", big.mark=','),
      paste('Most attended: ', tail(WorldCups["Country"],1)),
      icon = icon("trophy",lib = 'font-awesome'),
      color = "blue")
  })
  
  
  
  
  #Attendance Plot
  output$Attendance <- renderPlot(
    ggplot(WorldCupMatches) + xlim(input$YearRange2[1],input$YearRange2[2])+xlab("Year") + 
      theme(panel.background = element_rect(fill = '#1B8E2D', color = 'purple'), panel.grid.major = element_line(color = 'white', linetype = 'dotted')) +
      ylab("Attendance")+
      geom_histogram(bins = 50,color="lightblue" ,fill="white",mapping = aes(x= Year,fill = WorldCups$Attendance)
                     
  ))
    
  
  
  
  #World Cup Matches Data Frame
  output$WorldCupMatches <- DT::renderDataTable({
    DT::datatable(
      WorldCupMatches %>% filter(Year <= input$YearRange[2] & Year >= input$YearRange[1]),
      colnames = c('ID' = 1),
      rownames = TRUE,
      extensions = 'Buttons',
      options = list(
        autoWidth = FALSE, scrollX = TRUE,
        
        columnDefs = list(list(
          width = "80px", targets = c(4, 5,7,8,10,11,12,13,14,15,16,17,18,19,20), visible = FALSE
        )),
        pageLength = 9
        ))})
  
  
  #Match Attendance Plot 
 output$MatchAttendance<-renderPlot(
   
   WorldCupMatches %>%
     ggplot( aes(x=Attendance)) +
     geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8) +
     ggtitle("Attendance of all matches")
   ) 
 
 
 
 #Score Heat-Map Prediction
 
 # Score Grid Function 
 ScoreGrid<-function(homeXg,awayXg){
   
   A <- as.numeric()
   B <- as.numeric()
   
   for(i in 0:9) {
     A[(i+1)] <- dpois(i,homeXg)
     B[(i+1)] <- dpois(i,awayXg)
     }
   A[11] <- 1 - sum(A[1:10])
   B[11] <- 1 - sum(B[1:10])
   name <- c("0","1","2","3","4","5","6","7","8","9","10+")
   zero <- mat.or.vec(11,1)
   C <- data.frame(row.names=name, "0"=zero, "1"=zero, "2"=zero, "3"=zero, "4"=zero,
                   "5"=zero, "6"=zero, "7"=zero,"8"=zero,"9"=zero,"10+"=zero)
   for(j in 1:11) {
     for(k in 1:11) {
       C[j,k] <- A[k]*B[j]
     }
   }
   
   colnames(C) <- name
   
   return(round(C*100,2)/100)
 }
 
 
 ScoreHeatMap<-function(home,away,homeXg,awayXg,datasource){
   
   adjustedHome<-as.character(sub("_", " ", home))
   adjustedAway<-as.character(sub("_"," ",away))
   
   df<-ScoreGrid(homeXg,awayXg)
   
   df %>% 
     as_tibble(rownames = all_of(away)) %>%
     pivot_longer(cols = -all_of(away), 
                  names_to = home, 
                  values_to = "Probability") %>%
     mutate_at(vars(all_of(away), home), 
               ~forcats::fct_relevel(.x, "10+", after = 10)) %>% 
     ggplot() + 
     geom_tile(aes_string(x=all_of(away), y=home, fill = "Probability")) +   
     scale_fill_gradient2(mid="white", high = muted("red"))+
     theme(plot.margin = unit(c(1,1,1,1),"cm"),
           plot.title = element_text(size=20,hjust = 0.5,face="bold",vjust =4),
           plot.caption = element_text(hjust=1.1,size=10,face = "italic"), 
           plot.subtitle = element_text(size=12,hjust = 0.5,vjust=4),
           axis.title.x=element_text(size=14,vjust=-0.5,face="bold"),
           axis.title.y=element_text(size=14, vjust =0.5,face="bold"))+
     labs(x=adjustedAway,y=adjustedHome,
          caption=paste("Made By: KASMI Omar"))+
     ggtitle(label = "Expected Scores", subtitle = paste(adjustedHome, "vs",adjustedAway,"xG:",homeXg,"-",awayXg))
   
 }
 
 output$HeatMapSCore <- renderPlot(ScoreHeatMap(input$HomeTeam, input$AwayTeam, as.numeric(input$MinResult), as.numeric(input$MaxResult), "FiveThirtyEight"))
 
    
  
  
  #World cup Players goals PLOT 
  
  

   output$WorldCupPlayerGoals <- renderPlot(
     WorldCupPlayers %>% filter(Player.Name == input$PlayerName ) %>% group_by(Player.Name) %>% summarise(goal_total = sum(Goals)) %>% ggplot(aes(x = Player.Name, y = goal_total)) + 
       geom_histogram(stat="identity", aes(fill= goal_total)) 
     
     )

  
  
  #World cups Mapping
  
  
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addTiles()%>%
       addProviderTiles(providers$Stamen.Terrain) %>%
       addMarkers(lng =  df$longitude, lat = df$latitude,
                  popup = paste('<center>', df$Country, '</br>', df$Year ,'</br> Winner:',df$Winner,'</br> Year:',df$Year, '</center>' ),
                  labelOptions = labelOptions(textsize = "12px"),
                  )
  })
  
  
  output$TotalGoals <- renderPlot(
    WorldCups %>% ggplot(aes(x = WorldCups$Year, y = WorldCups$GoalsScored)) + 
      geom_histogram(stat="identity", aes(fill = GoalsScored ) ) +
      xlab("Year") + ylab("Scored Goals") 
      
    
  )
  
}
)
  
  
  
  

  
  
  


