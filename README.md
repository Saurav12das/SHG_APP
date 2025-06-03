# Soil Health Gap Project

This project assesses fluctuations in soil health within croplands as compared to native lands. The Soil Health Gap Index offers a quantitative metric for determining achievable goals and tracking progress in enhancing soil health.

## Requirements
Install the following R packages before running the scripts:

- shiny, leaflet, leaflet.extras, leaflet.extras2
- DT, bslib, shinydashboardPlus
- readxl, dplyr, parzer
- soilDB, sf, sp, rgdal, raster, leaflet.esri
- rmarkdown, rvest, rgeos

## Data Preparation
Run `get_wss_soil.R` to download Nebraska SSURGO polygons and join soil organic matter information. The script saves a GeoPackage at `data/ne_soil_om.gpkg`.

```r
source("get_wss_soil.R")
```

## Running the App
Start the Shiny application with:

```r
shiny::runApp("app.R")
```

The app loads the precipitation map and the soil organic matter layer and displays them on an interactive Leaflet map.
