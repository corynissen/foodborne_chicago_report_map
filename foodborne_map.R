
#############################################################################
# This file creates a borderless map of Chicago using the openstreetmap tiles
# and overlays the points from the submissions to foodborne chicago
# a file called foodborne_chicago_submissions.png is created
#############################################################################
library(ggplot2)
library(OpenStreetMap)
library(grid)
source("read_and_geocode.R") # will take a couple minutes to geocode

# keep only ones near chicago...
df2 <- subset(df, lat > 41.62 & lat < 42.05 & lng > -87.96 & lng < -87.5 
              & !is.na(lat) & !is.na(lng))

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
