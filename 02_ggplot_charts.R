library(tidyverse)
library(lubridate)
un <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=SEAT653URN") |>
  rename(date = 1, rate = 2) |>
  mutate(rate = as.numeric(rate), year = year(date), month = month(date, label = TRUE))
sum(is.na(un$rate))   # expect 1: Oct 2025, the shutdown month

glimpse(un)
summary(un)

##### First Plot - rate by month

ggplot(un, aes(date, rate)) +
  annotate('rect', xmin = as.Date('2007-12-01'), xmax = as.Date('2009-06-01'), ymin = -Inf, ymax = Inf, alpha = 0.2) +
  annotate('rect', xmin = as.Date('2020-02-01'), xmax = as.Date('2020-05-01'), ymin = -Inf, ymax = Inf, alpha = 0.2) +
  geom_line() +
  labs(title = "Seattle unemployment spiked to its highest level in 2020",
       subtitle = "Monthly, not seasonally adjusted",
       x = NULL, y = 'Percent', caption = 'Source: FRED(SEAT653URN)'
       ) + theme_minimal()

ggsave("charts/seattle_line.png", width = 8, height = 4.5, dpi = 300)

##### Second Plot - Average rate by year

yearly <- un |> group_by(year) |> 
  summarise(avg = mean(rate, na.rm = TRUE))

yearly |> arrange(desc(avg))

yearly |> filter(year < 2026) |>  
  ggplot(aes(year, avg, fill = year == 2010)) +
  scale_fill_manual(values = c("grey70", "steelblue"), guide = 'none') +
  annotate("text", x = 2010, y = 10.8, label = '10.3%') +
  geom_col() +
  labs(title = "Average annual unemployment rate was highest in 2010",
       subtitle = "Average rates by year, 1994–2025",
       x = NULL, y = 'Percent', caption = 'Source: FRED(SEAT653URN)'
       ) + theme_minimal()

ggsave("charts/seattle_bar.png", width = 8, height = 4.5, dpi = 300)

#2010 was the highest, where rebound was slow after a spike in unemployment rate
#na.rm is important because the missing entry from 2025 would exclude our 2025 bar as an entry


##### Third Plot - average rate by month (seasonal detection)

monthly <- un |> group_by(month) |>
  summarise(avg = mean(rate, na.rm = TRUE))

monthly |> ggplot(aes(month, avg, fill = month %in% c('Jan', 'Jun', 'Jul'))) +
  scale_fill_manual(values = c('grey70', 'steelblue'), guide = 'none') +
  geom_col() +
  labs(title = "Average monthly unemployment is highest in January and July, lowest in December",
       subtitle = "Average unemployment rate by month",
       x = NULL, y = 'Percent', caption = 'Source: FRED(SEAT653URN)') +
  geom_text(aes(label = round(avg, 1)), vjust = -0.5) +
  theme_minimal()

ggsave("charts/seattle_by_month.png", width = 8, height = 4.5, dpi = 300)

#January shows an increase in unemployment as seasonal workers end their term, and weather-dependent services decrease
#June and July show high unemployment, as graduates enter the job market and search for work. School-year workers also off payroll
#Unemployment trends down toward the end of the year, its lowest in December due to holiday hiring

##### Fourth Plot - US vs Seattle unemployment visual
us <- read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?id=UNRATENSA") |>
  rename(date = 1, us = 2) |>
  mutate(us = as.numeric(us))
sum(is.na(us$us)) #returns 1, so 1 missing month. US rate from US data

both <- un |>
  select(date, seattle = rate) |>
  left_join(us, by = 'date')
nrow(both)
head(both)

both_long <- both |> pivot_longer(c(seattle, us), names_to = "area", values_to = "rate")

both_long |> ggplot(aes(date, rate, color = area)) +
  scale_color_manual(values = c("steelblue", "grey50"), labels = c("Seattle Metro", "U.S.")) +
  geom_line() +
  labs(title = "Unemployment rates by month, US, vs Seattle Metro., 1994-2025",
       subtitle = "US unemployment is generally higher, but in recent years, Seattle seems to have higher unemployment",
       x = NULL, y = 'Percent', caption = "Source: FRED (SEAT653URN, UNRATENSA)")

ggsave("charts/seattle_vs_us.png", width = 8, height = 4.5, dpi = 300)


###



