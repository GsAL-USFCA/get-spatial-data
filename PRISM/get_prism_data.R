## make sure to install.packages()
library(prism)
library(rgdal)
library(raster)
library(sp)
library(sf)
library(tidyverse)

## prism directory - run this once
prism_set_dl_dir(paste0(getwd(), "/prismtmp"))
##

## this pulls the data - run this once
get_prism_monthlys(type = "ppt", year = 2003:2020, mon = 1:12, keepZip = FALSE)
##

## this pulls CA shapefile into memory and unions
url <- "https://www2.census.gov/geo/tiger/TIGER2016/COUSUB/tl_2016_06_cousub.zip"
temp <- tempfile()
temp2 <- tempfile()
download.file(url, temp)
unzip(zipfile = temp, exdir = temp2)
data <- readOGR(file.path(temp2, "tl_2016_06_cousub.shp"))
unlink(c(temp, temp2))
ca_mask <- st_read('tl_2016_06_cousub/tl_2016_06_cousub.shp')
ca_mask <- st_sf(st_union(ca_mask), crs = "4269") ## NAD83
##

## main loop for cropping and saving as .tif
prism_files <- prism_archive_ls()

for(prism_file in prism_files) {
  
  message(prism_file)
  prism_raster <- raster(pd_to_file(prism_file))
  
  cropped_prism <- prism_raster %>% 
    mask(ca_mask) %>% 
    crop(ca_mask) 
  
  writeRaster(cropped_prism, paste0("prism/", str_sub(prism_file, 1, -5), ".tif"), overwrite = TRUE)
  
}
##

##
rm(list = ls())
##
