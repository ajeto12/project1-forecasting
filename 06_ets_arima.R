library(tidyverse)
library(fpp3)

#un <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |> #Downloads FRED file into table
 # rename(date = 1, rate = 2) |>
  #mutate(rate = as.numeric(rate), month = yearmonth(date)) |> #Rate to numeric (nulls) and Date to Y-M
  #fill(rate, .direction = "down") |>     #fill null value from above (prior)
  #as_tsibble(index = month) |> #time series table
  #select(month, rate)  

un <- read_csv("SEAT653URN.CSV") |> # FRED website was down for maintanence. 
  rename(date = 1, rate = 2) |>
  mutate(rate = as.numeric(rate), month = yearmonth(date)) |> #Rate to numeric (nulls) and Date to Y-M
  fill(rate, .direction = "down") |>     #fill null value from above (prior)
  as_tsibble(index = month) |> #time series table
  select(month, rate)  

## Split train/test
train <- un |> filter_index(. ~ "2022 Dec") #from start of data to end 2022
test <- un |> filter_index("2023 Jan" ~ .) #from start 2023 to end of data
nrow(test) # check observations for test set

## Fit ETS and ARIMA, with SNaive kept as benchmark fit
fit <- train |> model(
  Snaive = SNAIVE(rate),
  ETS = ETS(rate),
  ARIMA = ARIMA(rate)
)

fit
fit |> select(ETS) |> report()
fit |> select(ARIMA) |> report()

## Forecast the test period, compared to SNaive benchmark
fc <- fit |> forecast(new_data = test)

fc |> autoplot(un |> filter_index("2021 Jan" ~ .), level = NULL) +
  labs(title = "ETS and ARIMA vs SNaive, Seattle unemployment)",
       subtitle = ".",
       y = "Rate (%)", x = NULL)

ggsave("charts/ets_arima.png", width = 8, height = 4.5, dpi = 300)


