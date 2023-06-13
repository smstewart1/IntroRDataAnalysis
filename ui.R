# Load required libraries
require(leaflet)


# Create a RShiny UI
shinyUI(
  fluidPage(padding=5,
  titlePanel("Bike-sharing demand prediction app"), 
  # Create a side-bar layout
  sidebarLayout(
    # Create a main panel to show cities on a leaflet map
    mainPanel(
      fluidPage(leafletOutput("city_bike_map", height = "1000"))
    ),
    # Create a side bar to show detailed plots for a city
    sidebarPanel(click = "plot_click", selectInput(inputId="city_dropdown", label = "Select City", choices = c("All", "Seoul", "Suzhou", "London", "New York", "Paris")),
                 conditionalPanel(condition = "inputID.city_dropdown" != "All", plotOutput("temperature")),
                conditionalPanel(condition = "inputID.city_dropdown" != "All", plotOutput("bike_plot", click = "click_plot")),
                conditionalPanel(condition = "inputID.city_dropdown" != "All", verbatimTextOutput("bike_date_output")),
                conditionalPanel(condition = "inputID.city_dropdown" != "All", plotOutput("humidity_plot"))

))))