library(tidyverse)
library(fpp3)

un <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |> #Downloads FRED file into table
  rename(date = 1, rate = 2) |>
  mutate(rate = as.numeric(rate), month = yearmonth(date)) |> #Rate to numeric (nulls) and Date to Y-M
  fill(rate, .direction = "down") |>     #fill null value from above (prior)
  as_tsibble(index = month) |> #time series table
  select(month, rate)  

un |> autoplot(rate)    # rate over time      
un |> gg_season(rate)        # seasonality
un |> ACF(rate, lag_max = 36) |> autoplot()   # autocorrelation, previous months

dcmp <- un |>           # Seasonal and Trend decomp using Loess
  model(STL(rate ~ season(window = "periodic"))) |> #explain rate using seasonal pattern that repeats each year
  components() # opens up the model
autoplot(dcmp)

dcmp |>
  as_tibble() |>   #strips time series structure
  group_by(m = month(month, label = TRUE)) |> # makes JAN-DEC column
  summarise(s = mean(season_year)) # averages seasonal effect by month

#####

# 1. Seasonally adjusted line (rate minus the seasonal part)
autoplot(dcmp, season_adjust) # season_adjust from dcmp components, smoothed out rate line

# 2. Subseries: one mini-panel per month, blue line = that month's average
un |> gg_subseries(rate) # each column is a month, blue line shows average, black line is observations over year

# 3. ACF of changes instead of levels
un |> ACF(difference(rate), lag_max = 36) |> autoplot() # shows autocorrelation to previous month change
un |> ACF(difference(rate, 12), lag_max = 36) |> autoplot() # shows autocorrelation to previous year change



p_stl <- autoplot(dcmp)
ggsave("charts/stl_decomposition.png", p_stl, width = 8, height = 6)

p_acf <- un |> ACF(difference(rate), lag_max = 36) |> autoplot() +
  labs(title = "ACF of monthly change in Seattle unemployment")
ggsave("charts/acf_diff.png", p_acf, width = 8, height = 5)



