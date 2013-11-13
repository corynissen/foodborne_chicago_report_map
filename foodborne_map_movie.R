
#############################################################################
# this file will create a movie / gif of the map that is created from the 
# foodborne_map.R script. It will plot one point at a time, create images, 
# then stitch them all together for a mpeg / gif. Imagemagick is used to do 
# this work. 
#############################################################################
library(ggplot2)
library(OpenStreetMap)
library(grid)
# run if you haven't run it already...
if(!exists("df")){source("read_and_geocode.R")} 

# do points overlayed on openstreetmap
merc <- projectMercator(df2$lat, df2$lng) #OSM uses mercator
# give openmap the upper right and lower left corners you want for your map
mp <- openmap(c(42.05, -87.96), c(41.62, -87.5), type="osm", minNumTiles=16)
# create animation
dir <- "for_animation"
p <- autoplot(mp) + 
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank())
filenames <- c()
for(i in letters){
  for(j in letters){
    filenames <- c(filenames, paste0(i,j))
  }
}
for(i in 1:nrow(merc)){
  p <- p + geom_point(aes(x=merc[1:i,1], y=merc[1:i,2]))
  ggsave(filename=paste0(dir, "/", filenames[i], ".jpg"), plot = p)
}

# resize images...
system(paste0("cd ", getwd(), 
              "/for_animation2 && mogrify -resize 500x500 *.jpg"))
# create mpg
system(paste0("cd ", getwd(), 
              "/for_animation && convert -delay 10 ", "*.jpg plot.mpg"))
# create animated gif
system(paste0("cd ", getwd(), 
              "/for_animation2 && convert -delay 10 -loop 0 *.jpg animation.gif"))
