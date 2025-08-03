# Bike Share Data Analysis - Business Intelligence for Revenue Optimization
# Analysis of Trips_2019_Q3.csv dataset

# Load required libraries
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(readr)
library(scales)

# Read the dataset
cat("Loading bike share data...\n")
bike_data <- read_csv("Trips_2019_Q3.csv")

# Basic data exploration
cat("Dataset dimensions:", dim(bike_data), "\n")
cat("Columns:", colnames(bike_data), "\n")

# Data cleaning and preprocessing
bike_data_clean <- bike_data %>%
  # Convert tripduration to numeric (remove quotes and commas)
  mutate(
    tripduration = as.numeric(gsub(",", "", tripduration)),
    start_time = as_datetime(start_time),
    end_time = as_datetime(end_time),
    start_date = as_date(start_time),
    start_hour = hour(start_time),
    start_day = wday(start_time, label = TRUE),
    trip_duration_minutes = tripduration / 60,
    # Create age groups from birthyear
    age = 2019 - birthyear,
    age_group = case_when(
      age < 25 ~ "18-24",
      age < 35 ~ "25-34", 
      age < 45 ~ "35-44",
      age < 55 ~ "45-54",
      age >= 55 ~ "55+",
      TRUE ~ "Unknown"
    )
  )

# Summary statistics
cat("\n=== SUMMARY STATISTICS ===\n")
cat("Total trips:", nrow(bike_data_clean), "\n")
cat("Unique bikes:", n_distinct(bike_data_clean$bikeid), "\n")
cat("Unique stations:", n_distinct(bike_data_clean$from_station_id), "\n")

# User type analysis
user_type_summary <- bike_data_clean %>%
  group_by(usertype) %>%
  summarise(
    count = n(),
    percentage = n() / nrow(bike_data_clean) * 100,
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE),
    total_revenue_estimate = count * ifelse(usertype == "Subscriber", 2, 5) # Rough estimate
  )

cat("\n=== USER TYPE ANALYSIS ===\n")
print(user_type_summary)

# Time-based analysis
hourly_usage <- bike_data_clean %>%
  group_by(start_hour) %>%
  summarise(
    trip_count = n(),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE)
  )

daily_usage <- bike_data_clean %>%
  group_by(start_day) %>%
  summarise(
    trip_count = n(),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE)
  )

# Popular routes analysis
popular_routes <- bike_data_clean %>%
  group_by(from_station_name, to_station_name) %>%
  summarise(
    trip_count = n(),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE)
  ) %>%
  arrange(desc(trip_count)) %>%
  head(20)

# Station utilization
station_usage <- bike_data_clean %>%
  group_by(from_station_name) %>%
  summarise(
    departures = n(),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE)
  ) %>%
  arrange(desc(departures)) %>%
  head(20)

# Age and gender analysis
demographics <- bike_data_clean %>%
  filter(!is.na(gender) & gender != "") %>%
  group_by(age_group, gender) %>%
  summarise(
    trip_count = n(),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE)
  )

# Revenue optimization analysis
revenue_analysis <- bike_data_clean %>%
  mutate(
    # Estimate revenue based on user type and duration
    estimated_revenue = case_when(
      usertype == "Subscriber" ~ 2, # Flat rate for subscribers
      usertype == "Customer" ~ 5 + (ceiling(trip_duration_minutes / 30) - 1) * 2 # Pay-per-use
    )
  ) %>%
  group_by(usertype) %>%
  summarise(
    total_trips = n(),
    total_revenue = sum(estimated_revenue),
    avg_revenue_per_trip = mean(estimated_revenue),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE)
  )

cat("\n=== REVENUE ANALYSIS ===\n")
print(revenue_analysis)

# Peak hour analysis for pricing optimization
peak_hour_revenue <- bike_data_clean %>%
  mutate(
    estimated_revenue = case_when(
      usertype == "Subscriber" ~ 2,
      usertype == "Customer" ~ 5 + (ceiling(trip_duration_minutes / 30) - 1) * 2
    )
  ) %>%
  group_by(start_hour) %>%
  summarise(
    trip_count = n(),
    total_revenue = sum(estimated_revenue),
    avg_revenue_per_trip = mean(estimated_revenue),
    customer_ratio = sum(usertype == "Customer") / n()
  )

cat("\n=== PEAK HOUR REVENUE ANALYSIS ===\n")
print(peak_hour_revenue %>% arrange(desc(total_revenue)) %>% head(10))

# Business Questions for Revenue Optimization
cat("\n" , rep("=", 80), "\n")
cat("BUSINESS QUESTIONS FOR REVENUE OPTIMIZATION\n")
cat(rep("=", 80), "\n\n")

cat("1. PRICING STRATEGY QUESTIONS:\n")
cat("   • How can we implement dynamic pricing during peak hours to maximize revenue?\n")
cat("   • What would be the optimal pricing structure for different user segments?\n")
cat("   • Should we introduce surge pricing during high-demand periods?\n\n")

cat("2. SUBSCRIPTION OPTIMIZATION:\n")
cat("   • How can we convert more casual customers to subscribers?\n")
cat("   • What subscription tiers would maximize customer lifetime value?\n")
cat("   • Should we offer different pricing for different age groups?\n\n")

cat("3. STATION OPTIMIZATION:\n")
cat("   • Which stations need more bikes during peak hours?\n")
cat("   • Where should we add new stations based on popular routes?\n")
cat("   • How can we reduce empty/full station issues?\n\n")

cat("4. OPERATIONAL EFFICIENCY:\n")
cat("   • What are the optimal bike redistribution strategies?\n")
cat("   • How can we reduce bike maintenance costs through usage patterns?\n")
cat("   • Which bikes are most/least utilized?\n\n")

cat("5. MARKETING AND RETENTION:\n")
cat("   • What are the characteristics of our most valuable customers?\n")
cat("   • How can we increase usage during off-peak hours?\n")
cat("   • What incentives would work best for different user segments?\n\n")

cat("6. EXPANSION OPPORTUNITIES:\n")
cat("   • Which areas show the highest growth potential?\n")
cat("   • What partnerships could increase usage (e.g., with transit, employers)?\n")
cat("   • How can we tap into seasonal usage patterns?\n\n")

# Generate specific insights
cat("KEY INSIGHTS FROM DATA ANALYSIS:\n")
cat("• Total trips in Q3 2019:", format(nrow(bike_data_clean), big.mark=","), "\n")
cat("• Subscriber vs Customer ratio:", 
    round(sum(bike_data_clean$usertype == "Subscriber") / nrow(bike_data_clean) * 100, 1), "% subscribers\n")
cat("• Average trip duration:", round(mean(bike_data_clean$trip_duration_minutes, na.rm = TRUE), 1), "minutes\n")
cat("• Peak usage hours:", paste(hourly_usage %>% arrange(desc(trip_count)) %>% head(3) %>% pull(start_hour), collapse = ", "), "\n")
cat("• Most popular day:", daily_usage %>% arrange(desc(trip_count)) %>% head(1) %>% pull(start_day), "\n")

cat("\nRECOMMENDED NEXT STEPS:\n")
cat("1. Implement dynamic pricing during peak hours (", 
    hourly_usage %>% arrange(desc(trip_count)) %>% head(3) %>% pull(start_hour) %>% paste(collapse = ", "), ")\n")
cat("2. Focus on converting customers to subscribers (higher revenue per trip)\n")
cat("3. Optimize bike distribution based on popular routes\n")
cat("4. Develop targeted marketing campaigns for underutilized time periods\n")
cat("5. Consider station expansion in high-demand areas\n")

cat("\nAnalysis complete! Check the console output for detailed insights.\n") 