# install.packages("fpp3")
library(tidyverse)
library(fpp3)

un <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |>
  rename(date = 1, rate = 2) |>
  mutate(rate = as.numeric(rate), month = yearmonth(date)) |>
  fill(rate, .direction = "down") |>      # filling the Oct 2025 NA with Sep's value
  as_tsibble(index = month) |>
  select(month, rate)

un |> autoplot(rate)          
# 1. We see no overall trend, but three unemployment shocks from the Dot Com bust ('01), The Great Recession ('08) and COVID ('20). '20 rebounds more quickly than the others.



un |> gg_season(rate)        
# 2. Most years sit between 2.5% and 7.5%, and follow the same shape. Recession years sit higher on, but keep the same shape. Increases in January and July, and a decrease in December. 



un |> ACF(rate, lag_max = 36) |> autoplot()   
# 3. Our plot shows autocorrelation fading slowly, indicating our series is not stationary. The observations wander rather than returning to a steady average.





