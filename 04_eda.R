library(tidyverse)
library(fpp3)

un <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |>
  rename(date = 1, rate = 2) |>
  mutate(rate = as.numeric(rate), month = yearmonth(date)) |>
  fill(rate, .direction = "down") |>     
  as_tsibble(index = month) |>
  select(month, rate)

un |> autoplot(rate)          
un |> gg_season(rate)        
un |> ACF(rate, lag_max = 36) |> autoplot()   

dcmp <- un |>
  model(STL(rate ~ season(window = "periodic"))) |>
  components()
autoplot(dcmp)

dcmp |>
  as_tibble() |>
  group_by(m = month(month, label = TRUE)) |>
  summarise(s = mean(season_year))

#####

# 1. Seasonally adjusted line (rate minus the seasonal part)
autoplot(dcmp, season_adjust)

# 2. Subseries: one mini-panel per month, blue line = that month's average
un |> gg_subseries(rate)

# 3. ACF of changes instead of levels
un |> ACF(difference(rate), lag_max = 36) |> autoplot()
un |> ACF(difference(rate, 12), lag_max = 36) |> autoplot()



p_stl <- autoplot(dcmp)
ggsave("charts/stl_decomposition.png", p_stl, width = 8, height = 6)

p_acf <- un |> ACF(difference(rate), lag_max = 36) |> autoplot() +
  labs(title = "ACF of monthly change in Seattle unemployment")
ggsave("charts/acf_diff.png", p_acf, width = 8, height = 5)



