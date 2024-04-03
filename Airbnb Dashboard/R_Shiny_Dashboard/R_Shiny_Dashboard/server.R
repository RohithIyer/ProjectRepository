#Copyright (c) 2024 -- 
#Licensed
#Written by Rohith Krishnamurthy 

library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(leaflet)

setwd("D:/Rohith NEU/ALY6070 Commn and Viz for Data Analysis/Final Project/R_Shiny_Dashboard/R_Shiny_Dashboard")

load("airbnb_cleaned.RData")

load("airbnb_calender.RData")

# Create a new factor variable for review score categories
airbnb_data <- dataset1 %>%
  mutate(review_category = case_when(
    review_scores_rating >= 95 ~ "Good",
    review_scores_rating < 95 & review_scores_rating >= 80 ~ "Average",
    review_scores_rating < 80 ~ "Below Average",
    TRUE ~ NA_character_  # This handles missing or NA values
  )) %>%
  mutate(review_category = factor(review_category, levels = c("Good", "Average", "Below Average")))

selected_columns <- c("id", "host_name", "street", "host_is_superhost", 
                      "host_neighbourhood", "host_listings_count", "neighbourhood_cleansed", 
                      "city", "property_type", "room_type", "accommodates", "bathrooms", 
                      "bedrooms", "beds", "bed_type", "weekly_price", "monthly_price", 
                      "cleaning_fee", "guests_included", "extra_people", "minimum_nights", 
                      "maximum_nights", "availability_365", "number_of_reviews", 
                      "review_scores_rating", "instant_bookable", "cancellation_policy")

# First, select the specified columns from airbnb_data
selected_airbnb_data <- select(airbnb_data, all_of(selected_columns))

merged_data <- inner_join(selected_airbnb_data, dataset2, by = c("id" = "listing_id"))



merged_data <- merged_data %>%
  mutate(date = as.Date(date), # Convert to Date format if it's not already
         day = day(date),
         month = month(date),
         year = year(date))

merged_data <- merged_data %>% 
  filter(available != 'f')

# Assuming merged_data is your dataset
merged_data <- merged_data %>%
  mutate(price = as.character(price), # Ensure price is treated as character for cleaning
         price = gsub("\\$", "", price), # Remove dollar signs
         price = gsub(",", "", price), # Remove commas if present
         price = as.numeric(price)) # Convert to numeric


function(input, output, session) {
  # Plot 1: Price by Neighbourhood
  output$pricePlot <- renderPlot({
    # Filter data based on the selected price range and neighbourhood
    filtered_data <- airbnb_data %>%
      filter(price >= input$priceRange[1], price <= input$priceRange[2],
             host_neighbourhood %in% input$neighbourhood)
    
    ggplot(filtered_data, aes(x = number_of_reviews, y = price, color = review_category)) +
      geom_point() +
      labs(title = "Filtered Plot by Price Range and Neighbourhood",
           x = "Number of Reviews",
           y = "Price") +
      scale_color_manual(values = c("Good" = "green", "Average" = "orange", "Below Average" = "red")) +
      theme_minimal()
  })
  
  # Plot 2: Listings by Neighbourhood
  output$neighbourhoodPlot <- renderPlot({
    # Filter data based on the selected inputs
    filtered_data <- airbnb_data %>%
      filter(price >= input$priceRange[1], price <= input$priceRange[2],
             number_of_reviews >= input$reviewRange[1], number_of_reviews <= input$reviewRange[2]) %>%
      filter(ifelse(input$reviewCategory == "All", TRUE, review_category == input$reviewCategory))
    
    # Aggregate data to count the number of listings in each neighbourhood
    neighbourhood_count <- filtered_data %>%
      group_by(host_neighbourhood) %>%
      summarise(number_of_listings = n(), .groups = 'drop') %>%
      arrange(desc(number_of_listings))
    
    # Generate the plot
    ggplot(neighbourhood_count, aes(x = reorder(host_neighbourhood, number_of_listings), y = number_of_listings)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(title = "Number of Properties Listed by Host Neighbourhood",
           x = "Host Neighbourhood",
           y = "Number of Listings")
  })
  
  # Plot 3: Average Price by Property Type
  output$avgPricePlot <- renderPlot({
    # Filter data based on the selected host_neighbourhood
    filtered_data <- airbnb_data %>%
      filter(host_neighbourhood == input$selectedNeighbourhood) %>%
      group_by(property_type) %>%
      summarise(avg_price = mean(price, na.rm = TRUE), .groups = 'drop') %>%
      arrange(desc(avg_price))
    
    # Generate the plot
    ggplot(filtered_data, aes(x = property_type, y = avg_price)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      geom_text(aes(label = sprintf("%.2f", avg_price)), # Format label to 2 decimal places
                position = position_stack(vjust = 0.5),  # Adjust vertical position
                color = "white", size = 3.5) +  # Set text color and size
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(title = paste("Average Price by Property Type in", input$selectedNeighbourhood),
           x = "Property Type",
           y = "Average Price ($)")
  })
  
  # Plot 4: Map View
  output$map <- renderLeaflet({
    # Filter the data based on input
    filtered_data <- airbnb_data %>%
      filter(host_neighbourhood %in% input$neighbourhood,
             property_type %in% input$propertyType,
             room_type %in% input$roomType,
             accommodates >= input$accommodates[1] & accommodates <= input$accommodates[2],
             price >= input$priceRange[1] & price <= input$priceRange[2],
             number_of_reviews >= input$numberOfReviews[1] & number_of_reviews <= input$numberOfReviews[2]) %>%
      mutate(popup_content = paste(property_type, " - $", price))
    
    # Create the map
    map <- leaflet(filtered_data) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~longitude, lat = ~latitude,
                       popup = ~popup_content,
                       radius = 5)
    
    map
  })
  
  # Plot 5: Price Trends by Month
  output$priceTrendPlot <- renderPlot({
    # Filter data based on the dropdown selections
    filtered_data1 <- merged_data %>%
      # Apply filters for property type and neighbourhood
      filter((input$selectedPropertyType == "All" | property_type == input$selectedPropertyType) &
               (input$selectedNeighbourhood == "All" | host_neighbourhood == input$selectedNeighbourhood)) %>%
      # Ensure 'date' is in Date format for month extraction
      mutate(date = as.Date(date, format = "%Y-%m-%d"),
             month = month(date, label = TRUE, abbr = TRUE)) %>%
      group_by(month) %>%
      summarise(average_price = mean(price, na.rm = TRUE), .groups = 'drop')
    
    ggplot(filtered_data1, aes(x = month, y = average_price, group = 1)) +
      geom_line(color='steelblue') +
      geom_point() +
      theme_minimal() +
      labs(title = paste("Average Price Trend for", input$selectedPropertyType,
                         "in", input$selectedNeighbourhood),
           x = "Month",
           y = "Average Price")
  })
}

