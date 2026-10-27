library(tidyverse)
library(fpp3)

un <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |> # download FRED file into a table
  rename(date = 1, rate = 2) |>                               # name the 2 columns date and rate
  mutate(rate = as.numeric(rate), month = yearmonth(date)) |> # rate to numeric (NAs), date to year-month
  fill(rate, .direction = "down") |>                          # fill the missing Oct 2025 value from the month before
  as_tsibble(index = month) |>                                # make it a time series table
  select(month, rate)

train <- un |> filter_index(. ~ "2022 Dec")  # all history up to end of 2022: the models learn from this
test  <- un |> filter_index("2023 Jan" ~ .)  # Jan 2023 to latest month: held back to grade the models

fit <- train |> model(            # fit 6 models on the training data (1 row, 6 model columns)
  Mean   = MEAN(rate),            # forecast = average of all history
  Naive  = NAIVE(rate),           # forecast = last month's value
  SNaive = SNAIVE(rate),          # forecast = same month last year
  Drift  = RW(rate ~ drift()),    # random walk (naive) plus a slope from first point to last
  ETS    = ETS(rate),             # error, trend, seasonal smoothing model
  ARIMA  = ARIMA(rate)            # autoregressive (past values), integrated (differencing), moving average (past errors)
)
fc <- fit |> forecast(new_data = test)  # forecast the test months with each fitted model

acc <- accuracy(fc, un) |>              # score each forecast against the actual data
  select(.model, RMSE, MAE, MAPE) |>    # keep the model name and 3 error measures (accuracy gives ~10)
  arrange(RMSE)                         # sort smallest error (best) first
acc                                     # print the table



fc |> filter(.model %in% c("ETS", "ARIMA", "SNaive")) |>        # top 3 models only
  autoplot(un |> filter_index("2018 Jan" ~ .), level = NULL) +  # draw against actual data from 2018 on, no shaded ranges
  labs(title = "ETS vs ARIMA vs seasonal naive, 2023–2026 test period",
       y = "Rate (%)", x = NULL)

ggsave("charts/model_comparison.png", width = 9, height = 5)

