# Census data R Scripts

The contents of this folder contain scripts that demostrate how to obtain data from the census using US Census Burueau API. 

* `med_inc_philly_map.R` = simple example on how to get axposed variables by table, running the API call and mapping the data using the [`tidycensus`](https://walker-data.com/tidycensus/) and [`mapview`](https://r-spatial.github.io/mapview/) packages. 

* `import_tidy_transform_viz.Rmd` = a beginners tutorial on the Tidyverse given to the RESET conference in March 2021 which includes data wrangling/transformation, pulling data from the census using `tidycensus` and basic visualization/mapping.

* `map-covid.R` = a demonstration on how to pull recent covid data from GitHub (source: [NYT](https://github.com/nytimes/covid-19-data)) and population estimates using `tidycensus`. Finally, rates per 100,000 are calculated and those rates are mapped using [leaflet](https://rstudio.github.io/leaflet/).