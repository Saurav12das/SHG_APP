# Script to download Nebraska SSURGO polygons and join soil organic matter values
# Requires: soilDB, sf, dplyr

library(soilDB)
library(sf)
library(dplyr)

# Fetch all SSURGO polygons for Nebraska
# Use Soil Data Access (SDA) service
ne_poly <- fetchSDA_spatial(WHERE = "areasymbol LIKE 'NE%'", as_Spatial = FALSE)

# Query surface horizon organic matter (chorizon table) by mukey
q <- "SELECT ch.mukey, AVG(ch.om_r) AS om
      FROM chorizon AS ch
      INNER JOIN mapunit AS mu ON ch.mukey = mu.mukey
      INNER JOIN legend AS l ON mu.lkey = l.lkey
      WHERE l.areasymbol LIKE 'NE%'
      GROUP BY ch.mukey"

om <- SDA_query(q)

# join to polygon via mukey
ne_soil_om <- ne_poly %>%
  left_join(om, by = 'mukey')

# Save as GeoPackage
if(!dir.exists('data')) dir.create('data')
st_write(ne_soil_om, 'data/ne_soil_om.gpkg', delete_dsn = TRUE)


