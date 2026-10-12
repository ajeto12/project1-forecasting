library(tidyverse)

series_id <- "SEAT653URN"
url <- paste0("https://fred.stlouisfed.org/graph/fredgraph.csv?id=", series_id)

raw <- read_csv(url)
glimpse(raw)

df <- raw |> rename(date = observation_date, value = SEAT653URN)
dir.create("data", showWarning = FALSE)
write_csv(df, "data/SEAT653URN.csv")

### Summary and plot


df |> summarise(
  first = min(date), last = max(date), n = n(),
  min = min(value, na.rm = TRUE),
  max = max(value, na.rm = TRUE),
  mean = mean(value, na.rm = TRUE)
)

ggplot(df, aes(date, value)) +
  geom_line() +
  labs(title = "Seattle-area unemployment rate, 1994-2026",
       subtitle = "Monthly, not seasonally adjusted",
       x = NULL, y = "Percent", caption = "Source: FRED (SEAT653URN)"
       )
ggsave("seattle_unemployment.png", width = 8, height = 4.5)

# You can see the volatility of the unemployment rate, and significant events like the '08 crisis, '20 pandemic
# The minimum is right before the pandemic. The max within this timeline is early quarantine in '20.
# Dot-com bust in '01-'03, Seattle's tech exposure is reflected there
# The shock in 2020, vs the slower recovery from 2008. In forecasting, we would have to decide how these would factor into future projections

#####

# Last 5 Years

df |>
  filter(date >= as.Date("2021-08-01")) |> 
  ggplot(aes(date, value)) +
  geom_line() + geom_point(size = 1) +
  labs(title = "seattle unemployment, last 5 years", x = NULL, y = "Percent")
ggsave("seattle_last5.png", width = 8, height = 4.5)

## In the last 5 years summary:
# Unemployment jumps up leading into the new year, due to seasonal jobs, climate-dependent jobs
# Hiring picks up around the end of Q1 each year
# Another bump in the summer, when recent grads enter employment
# Holiday hiring for Q4 leads rate to fall leading into new year
# Unemployment rate overall is trending upward over the past 5 years
# 2026 data is incomplete.


#Yearly averages
yearly <- df |>
  mutate(year = lubridate::year(date)) |>
  group_by(year) |>
  summarise(avg = mean(value, na.rm = TRUE))

ggplot(yearly, aes(year, avg))+
  geom_line() +
  labs(title = "seattle unemployment, yearly average", x = NULL, y = "Percent")
ggsave("seattle_yearly.png", width = 8, height = 4.5)

## Yearly Averages Takeaways
# Irregular patterns are cyclical, regular ones are seasonal
# We see several shocks over the span of the data
# 2020 shock overall looks less significant because unemployment rebounded back to normal levels more quickly
# 2026 data is incomplete.


# Project
# One of the strongest drivers of loan defaults is unemployment. Lenders forecast unemployment to prepare reserves to cover these losses.
# Seattle unemployment seems to display a clear seasonal pattern year-by-year, with a gradual rise from 3.2% in 2022 to around 5% in 2026.
# This project forecasts unemployment in the Seattle area for the next 12 months, and compares simple benchmark models to more advanced ones.


  
 Add data pull and first plots 

