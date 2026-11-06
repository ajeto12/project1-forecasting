library(tidyverse)
library(broom)   # tidy() and glance() turn lm output into tables

toy <- tibble(
  years  = c(0,1,2,3,4,5,6,8,10,12,15,20),
  degree = c(0,1,0,1,0,1,1,0,1,0,1,1),
  salary = c(38,44,41,50,45,55,58,52,68,60,82,90) * 1000
)

m1 <- lm(salary ~ years, data = toy)

tidy(m1)
glance(m1)

m2 <- lm(salary ~ years + degree, data = toy)

tidy(m2)
glance(m2)

us  <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=UNRATENSA") |>
  rename(date = 1, us = 2)
sea <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |>
  rename(date = 1, seattle = 2)

joined <- inner_join(sea, us, by = "date") |>
  fill(seattle, us) |>
  mutate(covid = if_else(date >= as.Date("2020-04-01") &
                           date <= as.Date("2021-06-01"), 1, 0))

m3 <- lm(seattle ~ us + covid, data = joined)
tidy(m3)
glance(m3)