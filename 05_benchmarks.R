library(tidyverse)
library(fpp3)

un <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |> #Downloads FRED file into table
  rename(date = 1, rate = 2) |>
  mutate(rate = as.numeric(rate), month = yearmonth(date)) |> #Rate to numeric (nulls) and Date to Y-M
  fill(rate, .direction = "down") |>     #fill null value from above (prior)
  as_tsibble(index = month) |> #time series table
  select(month, rate)  


## Split train/test
train <- un |> filter_index(. ~ "2022 Dec") #from start of data to end 2022
test <- un |> filter_index("2023 Jan" ~ .) #from start 2023 to end of data
nrow(test) # check observations for test set

## Fit mean, naive, snaive and drift
fit <- train |> model(
  Mean = MEAN(rate),
  Naive = NAIVE(rate),
  Snaive = SNAIVE(rate),
  Drift = RW(rate ~ drift())
)
fc <- fit |> forecast(new_data = test)

## Plot fit against reality

fc |> autoplot(un |> filter_index("2021 Jan" ~ .), level = NULL) +
  labs(title = "Benchmark forecasts vs actual Seattle unemployment",
       y = "Rate (%)", x = NULL)

#We zoom in and see that Snaive seems to follow the seasonal pattern reasonably well from 2023 - mid 2025
#Mean seems high at first but unemployment rises above it in late 2025
#Drift seems to be a poor fit in this particular test

accuracy(fc, un) |> select(.model, RMSE, MAE, MAPE)

#Confirms that Snaive had the best fit
#Typical miss is 0.75-0.9 percentage points (16% of the actual rate)


ggsave("charts/benchmarks.png", width = 8, height = 4.5, dpi = 300)


