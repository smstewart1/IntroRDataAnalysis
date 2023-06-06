# Load libraries
library(shiny)
library(tidyverse)

# Read in data
adult <- read_csv("adult.csv")
# Convert column names to lowercase for convenience 
names(adult) <- tolower(names(adult))

# Define server logic
shinyServer(function(input, output) {
  
  df_country <- reactive({
    adult %>% filter(native_country == input$country)
  })

  # TASK 5: Create logic to plot histogram or boxplot
  output$p1 <- renderPlot({
    if (input$graph_type == "histogram") {
      # Histogram
      ggplot(df_country(), aes_string(x = input$continous_variable)) + geom_histogram() + labs(x = "Distribution", y = "Count", title = paste("Trend of ", input$continous_variable)) + facet_wrap(~prediction)   # facet by prediction
    }
    else {
      # Boxplot
      ggplot(df_country(), aes_string("1", input$continous_variable)) + geom_boxplot() + coord_flip() + labs(y = "Count", title = paste("Trend of", input$continous_variable)) + facet_wrap(~prediction)
    }
  })
 
   # TASK 6: Create logic to plot faceted bar chart or stacked bar chart
  output$p2 <- renderPlot({
    # Bar chart
    p <- ggplot(df_country(), aes_string(x = input$categorical_variable)) + labs(x = "Category", y = "Count", title = paste("Trend of ", input$categorical_variable)) # modify theme to change text angle and legend position

    if (input$is_stacked) {
      p + geom_bar(position = "stack", aes(fill = prediction))  # add bar geom and use prediction as fill
    }
    else{
      p + geom_bar(aes_string(fill = input$categorical_variable)) + facet_wrap(~prediction)  # add bar geom and use input$categorical_variables as fill fill = input$categorical_variable
    }
 })
  
})
