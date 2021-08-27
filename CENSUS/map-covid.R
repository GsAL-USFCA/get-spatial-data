library(tidyverse)
library(tidycensus)
library(leaflet)

# GET COVID DATA FROM NYT - UPDATED DAILY-----------
# dates: PAST 4 WEEKS!
# NOTE: cases are CUMULATIVE
covid_flcounty <- readr::read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties-recent.csv") %>% 
  filter(state == "Florida") %>% 
  filter(county != "Unknown")

# get avg cases
covid_avg <- covid_flcounty %>% 
  group_by(county, fips) %>% 
  summarise(cases = mean(cases), deaths = mean(deaths)) %>% 
  ungroup()


# GET POPULATION COUNTS PER COUNTY ---------------

fl_county_pop <- get_estimates(geography = "county",
                               product = "population",
                               state = 12, 
                               geometry = TRUE) %>% 
  # filter for just the population product
  filter(variable %in% "POP") %>%
  # only need fips code and estimate (rename to pop)
  select(GEOID, pop = value)

# JOIN DATA AND GET RATE/100K ----------------------

# function to get rate/100k
adj_rate <- function(n, pop){
  (n/pop) * 100000
}

covid_fl_full <- covid_avg %>% 
  left_join(fl_county_pop, by = c("fips" = "GEOID")) %>% 
  mutate(case_rate = adj_rate(cases, pop),
         death_rate = adj_rate(deaths, pop))

# MAP DATA WITH LEAFLET-------------------------------

# must convert dataframe to spatial object first!
covid_sf <- sf::st_as_sf(covid_fl_full)

pal <- colorBin(
  palette = "Blues",
  domain = covid_fl_full$case_rate,
  pretty = TRUE)

covid_sf %>% 
  sf::st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%") %>% 
  addProviderTiles("Esri.WorldGrayCanvas") %>% 
  addPolygons(
    popup = ~ paste0(county,": ", format(round(case_rate), big.mark = ","), "/100k"),
    stroke = FALSE,
    smoothFactor = 0,
    fillOpacity = 0.7,
    color = ~pal(case_rate)
  ) %>% 
  addLegend("bottomleft", 
            pal = pal, 
            values = ~ case_rate,
            title = "COVID-19 Cases/100k People",
            opacity = 1)


