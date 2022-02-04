#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

dashboardPage( skin ="green",
               dashboardHeader(
                 title = img(src = "https://logodownload.org/wp-content/uploads/2017/05/fifa-logo.png", height = '38px', width = '100px')),
               dashboardSidebar(
                 sidebarMenu(
                   menuItem(h4(strong("Dashboard")), tabName = "dashboard" ),
                   menuItem(h4(strong("World Cup Matches")), tabName = "World_Cup_Matches"),
                   menuItem(h4(strong("World Cup Players")), tabName = "World_Cup_Players"),
                   menuItem(h4(strong("World Cups")), tabName = "World_Cups")
                 )),
               dashboardBody(
                 tabItems(
                   tabItem(tabName = "dashboard", h2("Welcome to the World Cups App"),
                           fluidRow(
                             valueBoxOutput("GoalsCard"),
                             valueBoxOutput("PlayerCard"),
                             valueBoxOutput("AttendanceCard")
                           ),
                             HTML('<center><iframe width="720" height="550" src="https://www.youtube.com/embed/6b5uph8c7n0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></center>')),
                 
                   
                   tabItem(tabName = "World_Cup_Matches", 
                           
                           box(
                             sliderInput("YearRange", "Year: ",
                                         min = YearMin , max = YearMax,value = c(1930,2014), step = 10),
                             title = "All Matches",
                             width = 6,
                             DT::dataTableOutput("WorldCupMatches"),
                             
                             
                           ),
                           box(plotOutput("MatchAttendance")),
                           box(
                             height = 450,
                             fluidRow(
                               column(width = 6, 
                                      selectInput(
                                        inputId = "HomeTeam",
                                        label = " Choose your Home Team",
                                        choices = unique(WorldCupMatches$Home.Team.Name),
                                        multiple = FALSE,
                                      )
                               ),
                               column(width = 6,
                                      selectInput(
                                        inputId = "AwayTeam",
                                        label = " Choose your Home Team",
                                        choices = unique(WorldCupMatches$Away.Team.Name),
                                        multiple = FALSE,
                                        ) 
                                      )
                             ),
                             
                             
                             
                             fluidRow(
                               column(width = 6, 
                                      selectInput(
                                        "MinResult",
                                        label= "Select minimum Prediction",
                                        choices = ScorePre,
                                        selected = "0.0"
                                        ),
                                      ),
                               column(width = 6, 
                                      selectInput(
                                        "MaxResult",
                                        label= "Select maximum Prediction",
                                        choices = ScorePre,
                                        selected = "10+.10"
                                        )
                                      )
                               
                             ),
                             plotOutput("HeatMapSCore" , height = 280)
                           )
                   ),
                   tabItem(tabName = "World_Cup_Players", 
                           
                           box(
                             width = 12,
                             
                             selectInput(inputId = "PlayerName",
                                         label = " Choose your Players",
                                         choices = unique(WorldCupPlayers$Player.Name),
                                         multiple = TRUE,
                                         selectize = TRUE,
                                         selected = "Alex THEPOT"
                                         ),
                             
                           
                             plotOutput("WorldCupPlayerGoals", )
                           
                           )
                   ),
                           
                   tabItem(tabName = "World_Cups",
                           
                           box(width = 12, title = "World cup Organisators",
                               leafletOutput("map")),
                           box(
                             sliderInput("YearRange2", "Year: ",
                                         min = YearMin , max = YearMax,value = c(1930,2014), step = 10),
                             title = "World Cup Attendance",
                             plotOutput("Attendance",height = 200),
                             height = 355
                           ),
                           box(
                             title = "World Cup Goals",
                             plotOutput("TotalGoals", height = 290,
                                        )
                           )
                          
                            
                          
                   )
                   
                 )
                 
               )

)
