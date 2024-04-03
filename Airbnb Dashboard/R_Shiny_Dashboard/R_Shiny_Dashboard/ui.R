#Copyright (c) 2024 -- 
#Licensed
#Written by Rohith Krishnamurthy 


library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(leaflet)

fluidPage(
  titlePanel("Airbnb Data Dashboard"),
  mainPanel(
    tabsetPanel(id = "tabs",
                tabPanel("Price by Neighbourhood",
                         sidebarLayout(
                           sidebarPanel(
                             sliderInput("priceRangeNeighbourhood",
                                         "Price Range:",
                                         min = min(airbnb_data$price, na.rm = TRUE),
                                         max = max(airbnb_data$price, na.rm = TRUE),
                                         value = c(min(airbnb_data$price, na.rm = TRUE), max(airbnb_data$price, na.rm = TRUE))),
                             selectInput("neighbourhoodNeighbourhood",
                                         "Neighbourhood:",
                                         choices = c("All", unique(airbnb_data$host_neighbourhood)),
                                         selected = "All",
                                         multiple = TRUE)
                           ),
                           mainPanel(plotOutput("pricePlot"))
                         )
                ),
                tabPanel("Listings by Neighbourhood",
                         sidebarLayout(
                           sidebarPanel(
                             sliderInput("priceRange",
                                         "Price Range:",
                                         min = min(airbnb_data$price, na.rm = TRUE),
                                         max = max(airbnb_data$price, na.rm = TRUE),
                                         value = c(min(airbnb_data$price, na.rm = TRUE), max(airbnb_data$price, na.rm = TRUE))),
                             sliderInput("reviewRange",
                                         "Number of Reviews Range:",
                                         min = min(airbnb_data$number_of_reviews, na.rm = TRUE),
                                         max = max(airbnb_data$number_of_reviews, na.rm = TRUE),
                                         value = c(min(airbnb_data$number_of_reviews, na.rm = TRUE), max(airbnb_data$number_of_reviews, na.rm = TRUE))),
                             selectInput("reviewCategory",
                                         "Review Category:",
                                         choices = c("All", unique(as.character(airbnb_data$review_category))),
                                         selected = "All")
                           ),
                           mainPanel(plotOutput("neighbourhoodPlot"))
                         )
                ),
                tabPanel("Average Price by Property Type",
                         sidebarLayout(
                           sidebarPanel(
                             selectInput("propertyTypeAvgPrice",
                                         "Property Type:",
                                         choices = c("All", unique(airbnb_data$property_type)),
                                         selected = "All")
                           ),
                           mainPanel(plotOutput("avgPricePlot"))
                         )
                ),
                tabPanel("Map View",
                         sidebarLayout(
                           sidebarPanel(
                             # Add inputs specific to the Map View here
                             selectInput("neighbourhood",
                                         "Host Neighbourhood:",
                                         choices = unique(airbnb_data$host_neighbourhood),
                                         selected = NULL,
                                         multiple = TRUE),
                             selectInput("propertyType",
                                         "Property Type:",
                                         choices = unique(airbnb_data$property_type),
                                         selected = NULL,
                                         multiple = TRUE),
                             selectInput("roomType",
                                         "Room Type:",
                                         choices = unique(airbnb_data$room_type),
                                         selected = NULL,
                                         multiple = TRUE),
                             sliderInput("accommodates",
                                         "Accommodates:",
                                         min = min(airbnb_data$accommodates, na.rm = TRUE),
                                         max = max(airbnb_data$accommodates, na.rm = TRUE),
                                         value = c(min(airbnb_data$accommodates, na.rm = TRUE), max(airbnb_data$accommodates, na.rm = TRUE)),
                                         step = 1),
                             sliderInput("priceRange",
                                         "Price Range:",
                                         min = min(airbnb_data$price, na.rm = TRUE),
                                         max = max(airbnb_data$price, na.rm = TRUE),
                                         value = c(min(airbnb_data$price, na.rm = TRUE), max(airbnb_data$price, na.rm = TRUE))),
                             sliderInput("numberOfReviews",
                                         "Number of Reviews:",
                                         min = 0,
                                         max = max(airbnb_data$number_of_reviews, na.rm = TRUE),
                                         value = c(0, max(airbnb_data$number_of_reviews, na.rm = TRUE)))
                             # Add more filters as needed
                           ),
                           mainPanel(leafletOutput("map"))
                         )
                ),
                tabPanel("Price Trends by Month",
                         sidebarLayout(
                           sidebarPanel(
                             selectInput("selectedPropertyType",
                                         "Property Type:",
                                         choices = c("All", unique(merged_data$property_type)),
                                         selected = "All"),
                             selectInput("selectedNeighbourhood",
                                         "Neighbourhood:",
                                         choices = c("All", unique(merged_data$host_neighbourhood)),
                                         selected = "All")
                           ),
                           mainPanel(plotOutput("priceTrendPlot"))
                         )
                )
    )
  )
)

