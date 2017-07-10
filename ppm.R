library(sp)
library(leaflet)
library(ggplot2)
library(stringr)

rm(list = ls())
setwd("~/pCloudDrive/2017 esra/data/ppm-sites")

# Read in the SpatialPolygonsDataFrame
ind.border <- readRDS("IND_adm0.rds") # border around India
ind.shp <- readRDS("IND_adm2.rds") # border at the district level
# Look at ind.shp
# The data in ind.shp looks exactly like in IND_adm*.csv in the shape file
class(ind.shp) # SpatialPolygonsDF
head(ind.shp@data)
tail(ind.shp@data)

# Read in data. File adm2.csv was created from IND_adm*.csv in the shape file. 
# I kept the OBJECTID column (for merging) and added a column to indicate whether there was a ppm.
data <- read.csv("adm2.csv")

# Change NAs in ppm column of data to 0 (meaning no study at this location)
data$ppm[is.na(data$ppm)] <- 0 

# Merge shapefile with PPM data
ind.shp@data <- merge(ind.shp@data, data, by = "OBJECTID")

# Change label of district from "West" to "Delhi"
ind.shp[ind.shp$NAME_2 == "West", "NAME_2"] <- "Delhi" # id 416

#look at the data of dprk.shp
ind.map2 <- ind.shp@data 

# Chosen colors
col <- c("#deebf7", "#08306b") # blue
col <- c("#fff5eb", "#a63603") # dark brown
col <- c("#fff5f0", "#fd8d3c") # Orange
col <- c("#c7e9c0", "#238b45") # green
# Create color pallete. colorFactor is used for categorical data.
# can also do palette = "Reds"
factpal <- colorFactor(palette = col, domain = ind.shp$ppm)

# Create labels for map later. Generate label with HTML, and passing it to lapply() so that Leaflet knows
# to treat each label as HTML rather than plain text.
labels <- sprintf(
  "<strong>%s</strong><br/>State: %s",
  ind.shp$NAME_2, ind.shp$NAME_1
) %>% lapply(htmltools::HTML)

title <- "PPM Study Sites in India by District, 1995-2007 
<br/>Data of administrative boundaries from GADM.org"

popup1 <- "Zoom out to see the whole India."
popup2 <- "Hover over a district to see its name."
  
# Base map
m <- leaflet() %>%
	# addTiles() %>%
	setView(lng = 82, lat = 16, zoom = 6) %>%
  addProviderTiles("Esri.WorldGrayCanvas")
  
# MapBox tile
  # addProviderTiles("MapBox", options = providerTileOptions(
  #   id = "mapbox.light",
  #   accessToken = "pk.eyJ1IjoiZ25ydWRkZXJoYW0iLCJhIjoiY2o0d2N0dmNzMTVpazJxbnJpZ3Q3MmM2dSJ9.LWLLjWZqqLBjnsntFNpIBA")
  # )
# OpenStreetMap Black White tile
  # addProviderTiles("OpenStreetMap.BlackAndWhite")

# Add polygons to map
m %>%
  # India border
  addPolygons(data = ind.border,
              # stroke
              color = "#666", weight = 2, opacity = 1,
              # fill of polygons
              fill = F
              ) %>%
  # Border at the district level
 	addPolygons(data = ind.shp, 
	            # stroke
	            color = "white", weight = 1, opacity = 2, dashArray = "3",
	            # fill of polygons, fillOpacity = 0.1 is very transparent, 1 is solid.
	            fillOpacity = 0.7, fillColor = factpal(ind.shp$ppm),
	            # this highlight option brings polygons to front when hovering mouse on them
	            highlight = highlightOptions(color = "#666", weight = 3, bringToFront = T,
	                                         fillOpacity = 0.7, dashArray = ""),
	            # the labelOptions set style of labels
	            label = labels,
	            labelOptions = labelOptions(
	              style = list("font-weight" = "normal", padding = "3px 8px"),
	              textsize = "15px",
	              direction = "auto"
	            )
	            ) %>%
  addLegend(position = "bottomright", colors = col, title = title,
            labels = c("No PPM studies", "PPM study sites"), opacity = 0.7) %>%
  addPopups(lng = 86, lat = 16 , popup = popup1) %>%
  addPopups(lng = 79, lat = 12, popup = popup2) # %>%
  #addLabelOnlyMarkers(lng = 86, lat = 16, label = popup1) #doesn't show