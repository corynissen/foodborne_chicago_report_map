
#############################################################################
# This file creates a borderless map of Chicago using the openstreetmap tiles
# and overlays the points from the submissions to foodborne chicago
# a file called foodborne_chicago_submissions.png is created
# Chicago city shapefiles downloaded from: http://goo.gl/8bHX1l
#############################################################################

library(ggplot2)
library(OpenStreetMap)
library(grid)
library(ggmap)
library(rgdal)
# run if you haven't run it already...
if(!exists("df")){source("read_and_geocode.R")} 

# keep only ones near chicago...
df2 <- subset(df, lat > 41.62 & lat < 42.05 & lng > -87.96 & lng < -87.5 
              & !is.na(lat) & !is.na(lng))

# graph using OpenStreetMap package
merc <- projectMercator(df2$lat, df2$lng) #OSM uses mercator
# give openmap the upper right and lower left corners you want for your map
mp <- openmap(c(42.05, -87.96), c(41.62, -87.5), type="osm", minNumTiles=16)
p <- autoplot(mp) + geom_point(aes(x=merc[,1], y=merc[,2]), alpha=.7, size=10) +
     theme(line = element_blank(),
           text = element_blank(),
           line = element_blank(),
           title = element_blank(),
           plot.margin=unit(c(0,0,0,0), "cm"))

gt <- ggplot_gtable(ggplot_build(p))
ge <- subset(gt$layout, name == "panel")
png("foodborne_chicago_submissions.png", width=1433, height=1800)
grid.draw(gt[ge$t:ge$b, ge$l:ge$r])
dev.off()

# same graph using ggmap package
p2 <- qmap("chicago") + geom_point(data=df2, aes(x=lng, y=lat)) +
    coord_cartesian(xlim=c(-87.96, -87.5), ylim=c(41.62, 42.05))
ggsave(plot=p2, "foodborne_chicago_submissions2.png", height=5, width=5)

# now add shapefile info
shapefile <- readOGR("chicago_city_shapefiles", "City_Boundary")
shapefile.converted <- spTransform(shapefile, CRS("+proj=longlat +datum=WGS84"))
p3 <- p2 + geom_polygon(aes(x = long, y = lat, group=group), alpha=.2, 
                 data = shapefile.converted) + 
    coord_cartesian(xlim=c(-87.96, -87.5), ylim=c(41.62, 42.05))
ggsave(plot=p3, "foodborne_chicago_submissions3.png", height=5, width=5)
