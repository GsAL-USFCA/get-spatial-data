library(tidycensus)
library(tidyverse)
library(mapview)

v19 <- tidycensus::load_variables(year = 2019,
                                  dataset = "acs5/subject") %>% 
  # tabe S1903 = median income in the past 12-mos (2019 inflation adjusted)
  filter(str_detect(name, "S1903"))

med_inc <- get_acs(geography = "tract", 
                   # PA
                   state = 42, 
                   # Philadelphia County
                   county = 101, 
                   year = 2019,
                   # estimate based on median household income
                   variables = c(med_inc = "S1903_C03_001"), 
                   geometry = TRUE)

med_inc %>% 
  mapview::mapview(zcol = "estimate", legend = TRUE)
