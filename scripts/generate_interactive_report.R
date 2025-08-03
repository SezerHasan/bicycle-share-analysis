# Interactive HTML Report Generator for Bike Share Analysis
# Creates a professional, interactive dashboard with embedded visualizations

# Load required libraries
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(readr)
library(scales)
library(plotly)
library(flexdashboard)
library(DT)
library(knitr)
library(rmarkdown)

# Read and clean the data
bike_data <- read_csv("../data/Trips_2019_Q3.csv")

bike_data_clean <- bike_data %>%
  mutate(
    tripduration = as.numeric(gsub(",", "", tripduration)),
    start_time = as_datetime(start_time),
    end_time = as_datetime(end_time),
    start_date = as_date(start_time),
    start_hour = hour(start_time),
    start_day = wday(start_time, label = TRUE),
    trip_duration_minutes = tripduration / 60,
    age = 2019 - birthyear,
    age_group = case_when(
      age < 25 ~ "18-24",
      age < 35 ~ "25-34", 
      age < 45 ~ "35-44",
      age < 55 ~ "45-54",
      age >= 55 ~ "55+",
      TRUE ~ "Unknown"
    ),
    estimated_revenue = case_when(
      usertype == "Subscriber" ~ 2,
      usertype == "Customer" ~ 5 + (ceiling(trip_duration_minutes / 30) - 1) * 2
    ),
    is_peak_hour = start_hour %in% c(16, 17, 18),
    is_weekend = start_day %in% c("Sat", "Sun"),
    is_customer = usertype == "Customer"
  )

# Create interactive visualizations
# 1. Hourly Usage Pattern (Interactive)
hourly_usage <- bike_data_clean %>%
  group_by(start_hour) %>%
  summarise(
    trip_count = n(),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE),
    total_revenue = sum(estimated_revenue),
    customer_ratio = sum(usertype == "Customer") / n()
  )

p1 <- plot_ly(hourly_usage, x = ~start_hour, y = ~trip_count, type = 'scatter', mode = 'lines+markers',
               name = 'Trip Count', line = list(color = '#1f77b4', width = 3)) %>%
  add_trace(y = ~total_revenue/1000, yaxis = 'y2', name = 'Revenue (K$)', 
            line = list(color = '#ff7f0e', width = 3)) %>%
  layout(title = 'Hourly Trip Distribution and Revenue',
         xaxis = list(title = 'Hour of Day'),
         yaxis = list(title = 'Number of Trips', side = 'left'),
         yaxis2 = list(title = 'Revenue (Thousands $)', side = 'right', overlaying = 'y'),
         hovermode = 'x unified')

# 2. Daily Usage Pattern (Interactive)
daily_usage <- bike_data_clean %>%
  group_by(start_day) %>%
  summarise(
    trip_count = n(),
    total_revenue = sum(estimated_revenue),
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE)
  )

p2 <- plot_ly(daily_usage, x = ~start_day, y = ~trip_count, type = 'bar',
               marker = list(color = '#2ca02c', opacity = 0.8)) %>%
  layout(title = 'Daily Trip Distribution',
         xaxis = list(title = 'Day of Week'),
         yaxis = list(title = 'Number of Trips'))

# 3. User Type Analysis (Interactive)
user_type_summary <- bike_data_clean %>%
  group_by(usertype) %>%
  summarise(
    count = n(),
    percentage = n() / nrow(bike_data_clean) * 100,
    avg_duration = mean(trip_duration_minutes, na.rm = TRUE),
    total_revenue = sum(estimated_revenue),
    avg_revenue_per_trip = mean(estimated_revenue)
  )

p3 <- plot_ly(user_type_summary, labels = ~usertype, values = ~count, type = 'pie',
               textinfo = 'label+percent', insidetextorientation = 'radial') %>%
  layout(title = 'User Type Distribution')

# 4. Trip Duration Distribution (Interactive)
p4 <- plot_ly(bike_data_clean %>% filter(trip_duration_minutes <= 120), 
               x = ~trip_duration_minutes, type = 'histogram', nbinsx = 50,
               marker = list(color = '#9467bd', opacity = 0.7)) %>%
  layout(title = 'Trip Duration Distribution (≤ 2 hours)',
         xaxis = list(title = 'Trip Duration (minutes)'),
         yaxis = list(title = 'Frequency'))

# 5. Revenue by User Type and Duration (Interactive)
revenue_by_duration <- bike_data_clean %>%
  mutate(duration_bin = cut(trip_duration_minutes, 
                           breaks = seq(0, 120, 10), 
                           labels = paste0(seq(0, 110, 10), "-", seq(10, 120, 10)))) %>%
  group_by(usertype, duration_bin) %>%
  summarise(
    trip_count = n(),
    total_revenue = sum(estimated_revenue),
    avg_revenue = mean(estimated_revenue)
  ) %>%
  filter(!is.na(duration_bin))

p5 <- plot_ly(revenue_by_duration, x = ~duration_bin, y = ~avg_revenue, color = ~usertype, 
               type = 'bar', opacity = 0.8) %>%
  layout(title = 'Average Revenue by Trip Duration and User Type',
         xaxis = list(title = 'Trip Duration (minutes)'),
         yaxis = list(title = 'Average Revenue ($)'),
         barmode = 'group')

# 6. Peak Hour Revenue Analysis (Interactive)
p6 <- plot_ly(hourly_usage, x = ~start_hour, y = ~customer_ratio, type = 'scatter', mode = 'lines+markers',
               marker = list(color = '#d62728', size = 8), line = list(color = '#d62728', width = 3)) %>%
  layout(title = 'Customer Ratio by Hour (Higher = More Pay-per-Use)',
         xaxis = list(title = 'Hour of Day'),
         yaxis = list(title = 'Ratio of Customers (vs Subscribers)', tickformat = ',.0%'))

# Save interactive plots
saveRDS(p1, "../plots/hourly_usage_interactive.rds")
saveRDS(p2, "../plots/daily_usage_interactive.rds")
saveRDS(p3, "../plots/user_type_interactive.rds")
saveRDS(p4, "../plots/duration_dist_interactive.rds")
saveRDS(p5, "../plots/revenue_duration_interactive.rds")
saveRDS(p6, "../plots/customer_ratio_interactive.rds")

# Create summary statistics for the report
summary_stats <- list(
  total_trips = nrow(bike_data_clean),
  unique_bikes = n_distinct(bike_data_clean$bikeid),
  unique_stations = n_distinct(bike_data_clean$from_station_id),
  subscriber_percentage = round(sum(bike_data_clean$usertype == "Subscriber") / nrow(bike_data_clean) * 100, 1),
  avg_trip_duration = round(mean(bike_data_clean$trip_duration_minutes, na.rm = TRUE), 1),
  peak_hours = paste(hourly_usage %>% arrange(desc(trip_count)) %>% head(3) %>% pull(start_hour), collapse = ", "),
  total_revenue = sum(bike_data_clean$estimated_revenue)
)

saveRDS(summary_stats, "../reports/summary_stats.rds")

cat("Interactive visualizations and summary statistics generated successfully!\n") 