#libraries
library(shiny)
library(leaflet)
library(DT)
library(readxl)
library(dplyr)
library(parzer)
library(leaflet.extras)
library(leaflet.extras2)
library(bslib)
library(shinydashboardPlus)
library(rgdal)
library(raster)
library(sp)
library(leaflet.esri)
library(rmarkdown)
library(rvest)
library(rgeos)
library(sf)
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

#30 year normal precipitation shape file
precip <- readOGR("NE_Precipitaion_Map")
precip <- spTransform(precip, CRS("+proj=longlat +datum=WGS84"))


#data
Data <- read_excel("Data.xlsx")

#converting the lat and long column to degree decimal and saving it to a new dataframe
df <- Data %>%
  mutate(Lon = parzer::parse_lon(Lon),
         Lat = parzer::parse_lat(Lat))

df_REF <- df %>% filter(Land_Suitability == "Reference")
df_CRP <- df %>% filter(Land_Suitability == "Cropland")

#color group
pal <- colorFactor(palette = c("purple", "green"),
                   levels = c("Reference", "Cropland"))

#precipitation vector for the map
precip_in <- precip@data$Inches

#creating continuous color numeric for the precipitation map
nc_pal <- colorNumeric(palette = c("#FF9191", "purple", "green"), domain = precip_in)


ui <- function(){
  navbarPage(
    title = ("Soil Health Gap Project"),
    tabPanel(
      "Map",
      leafletOutput("map", height = 1000),
      #sidebar panel to upload the shape file for analysis
      sidebarLayout(
        mainPanel = "",
        sidebarPanel(
          width = 12,
          fluid = T,
          position = c("left", "right"),
          fileInput(
            inputId = "filemap",
            label = "Upload shapefile : To overlay and geospatial analysis",
            multiple = TRUE,
            accept = c(".shp", ".dbf", ".sbn", ".sbx", ".shx", ".prj")
          )
        )
      )
    ),
    tabPanel("Site Information", DT::dataTableOutput("data")),
    navbarMenu(
      "More",
      tabPanel("About the project",
               fluidRow(includeMarkdown("about.Rmd"))),
      tabPanel("Contact",
               includeMarkdown("contact.Rmd")),
      tabPanel("Reference Materials",
               includeMarkdown("reference.Rmd"))
    )
  )
}


server <- function(input, output) {
  #leaflet map
  output$map <- renderLeaflet({
    map_base = leaflet() %>%
      addTiles(group = "OSM (default)") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "ESRI") %>%
      addProviderTiles(providers$Esri.WorldImagery,
                       group = "World Imagery") %>%
      addPolygons(
        data = precip, opacity = 10, fillColor = ~nc_pal(precip_in), stroke = T, color = "black", weight = 0.7,
        label = ~paste0("precipitation: ", precip_in),
        highlight = highlightOptions(
          weight = 3,
          color = "red",
          bringToFront = T
        ), group = "Precipitaion"
      ) %>% addLegend(colors = nc_pal(precip_in), labels = precip_in, 
                      title = "Precipitation (in)", position = "bottomright", group = "Precipitaion")
    
    #map using map_base layer as primary
    map = map_base %>% addCircleMarkers(
        data = df_REF, lng = df_REF$Lon, lat = df_REF$Lat,
        group = "Reference",
        radius = 10,
        fillColor = ~ pal(Land_Suitability), color = "black",
        popup = paste0(
          "<b>Name = </b>",
          df_REF$Name,
          "<br>",
          "<b>Land_Suitability = </b>",
          df_REF$Land_Suitability,
          "<br>",
          "<b>Location = </b>",
          df_REF$Location,
          "<br>",
          "<b> County = </b>",
          df_REF$County
        )
      ) %>%
      addCircleMarkers(
        group = "Cropland",
        data = df_CRP,
        radius = 10,
        fillColor = ~ pal(Land_Suitability), color = "black",
        popup = paste0(
          "<b>Name = </b>",
          df_CRP$Name,
          "<br>",
          "<b>Land_Suitability = </b>",
          df_CRP$Land_Suitability,
          "<br>",
          "<b>Location = </b>",
          df_CRP$Location,
          "<br>",
          "<b> County = </b>",
          df_CRP$County
        )
      ) %>%
      addCircleMarkers(
        group = "Reference",
        radius = 10,
        color = "purple",-96.8063888549805,
        40.8688888549805,
        popup = paste0(
          "<b>Name = </b>",
          "<b><a href = 'https://grassland.unl.edu/nine-mile-prairie'> Nine-Mile Prairie</a></b>",
          "<br>",
          "<b>Land_Suitability = </b>",
          "Reference",
          "<br>",
          "<b>Location = </b>",
          "Lincoln",
          "<br>",
          "<b> County = </b>",
          "Lancaster"
        )
      ) %>% addLayersControl(
        baseGroups = c("OSM (default)", "ESRI", "World Imagery"),
        overlayGroups = c("Precipitaion","Reference", "Cropland"), options = layersControlOptions(collapsed = F),
      ) %>%
      addSearchOSM() %>%
      addResetMapButton()
  })
  
  #data table
  output$data <- DT::renderDataTable(datatable(df))
}

shinyApp(ui = ui, server = server)
