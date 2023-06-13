# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API
# and make predictions
source("model_prediction.R")


test_weather_data_generation<-function(){
  #Test generate_city_weather_bike_data() function
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}

# Create a RShiny server
shinyServer(function(input, output){
  # Define a city list
  city_list <- read.csv("selected_cities.csv")
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  city_weather_bike_df <- test_weather_data_generation()
  
  # Create another data frame called `cities_max_bike` with each row contains city location info and max bike
  # prediction for the city
  predictions <- generate_city_weather_bike_data()
  cities_max_bike <- predictions %>% group_by(CITY_ASCII) %>% slice_max(BIKE_PREDICTION)

  observeEvent(input$city_dropdown, {
    if(input$city_dropdown != 'All') {
      #builds up temperature vs t plot
      choices <- c("All", "Seoul", "Suzhou", "London", "New York", "Paris")
      long_df <- get_weather_forecaset_by_cities(choices)
      short_df <- head(long_df[long_df$CITY_ASCII == input$city_dropdown,], n = 8)
      p <- ggplot(short_df, aes(x = HOURS, y = TEMPERATURE, label = TEMPERATURE)) + xlab("Date and Time") + ggtitle("Temperature Chart") + ylab("Temperature (C)") + geom_line(color = "yellow")+ geom_point() + geom_text(position = position_jitter(width = 1,height = 2))      
      output$temperature <- renderPlot(p)
      
      #generates bike sharing data
      shortbike_df <- predictions[predictions$CITY_ASCII == input$city_dropdown,]
      q <- ggplot(shortbike_df, aes(x = FORECASTDATETIME, y = BIKE_PREDICTION, label = BIKE_PREDICTION)) + 
                                       xlab("Time (3 hours ahead)") + ggtitle("Bike Prediction Chart") + ylab("Bike Prediction") + 
                                       geom_line(linetype = 2)+ geom_point() + geom_text(position = position_jitter(width = 0, height = 1)) + 
                                       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
      output$bike_plot <- renderPlot(q) 
      
      #render bike prediction
      output$bike_date_output <- renderText(paste("Date/Time = ", input$click_plot$x, "\n Bike Demand = ", input$click_plot$y))
      
      #plot of humidity
      r <- ggplot(shortbike_df, aes(x = HUMIDITY, y = BIKE_PREDICTION, label = BIKE_PREDICTION)) + 
        xlab("Humidity") + ggtitle("Bike Prediction vs Humidity") + ylab("Bike Prediction") + 
        geom_point() + geom_smooth(formula = y ~ poly(x, 4), method = lm)
      output$humidity_plot <- renderPlot(r) 
  
      #generates leaflet
      site <- cities_max_bike[cities_max_bike$CITY_ASCII == input$city_dropdown,]
      output$city_bike_map <- renderLeaflet({leaflet() %>% addProviderTiles(providers$OpenStreetMap.Mapnik) %>% addCircleMarkers(lng = site$LNG, lat = site$LAT, popup = site$DETAILED_LABEL, color = "blue")
      
      })  
      #Render the city overview map
    }
    else {
      output$city_bike_map <- renderLeaflet({leaflet() %>%
          addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
          addCircleMarkers(lng = cities_max_bike$LNG, lat = cities_max_bike$LAT, popup = cities_max_bike$DETAILED_LABEL, color = color_levels(cities_max_bike$BIKE_PREDICTION_LEVEL))
    })
  }
  # If just one specific city was selected, then render a leaflet map with one marker
  # on the map and a popup with DETAILED_LABEL displayed
  
})
})
