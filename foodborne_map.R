
library(RCurl)
library(RJSONIO)
library(ggplot2)
library(OpenStreetMap)
library(grid)

df <- read.csv("submissions-2013-11-05.csv", stringsAsFactors=F)
names(df) <- tolower(names(df))
# order by id, or basically date
df <- df[order(df$id),]

# replace spaces with '+' in address to use this
geocoder.url <- "http://rpc.geocoder.us/service/csv?address="
geocoder.url.google.1 <- "http://maps.googleapis.com/maps/api/geocode/json?address="
geocoder.url.google.2 <- "&sensor=false"

df$geocode.json <- df$geocode <- df$lat <- df$lng <- rep(NA, nrow(df))
# do this in a loop since we have to sleep to avoid google's rate limiting
for(i in 1:nrow(df)){
  fail <- FALSE
  rest.address <- ifelse(grepl("chicago", df$restaurant.address[i], 
                               ignore.case=T), df$restaurant.address[i],
                         paste0(df$restaurant.address[i], ", Chicago IL"))
  df$geocode.json[i] <- getURL(paste0(geocoder.url.google.1,
    gsub(" ", "+", rest.address), geocoder.url.google.2))
  geocode.list <- fromJSON(df$geocode.json[i])
    if(geocode.list$status=="OK"){
      if(!is.null(geocode.list$results)){
        df$geocode[i] <-geocode.list$results
        df$lat[i] <- ifelse(length(df$geocode[i]) > 0, 
                            df$geocode[i][[1]]$geometry$location["lat"], NA)
        df$lng[i] <- ifelse(length(df$geocode[i]) > 0, 
                            df$geocode[i][[1]]$geometry$location["lng"], NA)
      }else{
        fail <- TRUE
      }
    }else{
      fail <- TRUE      
    }
  if(fail){
    df$geocode[i] <- df$lat[i] <- df$lng[i] <- NA
  }
  Sys.sleep(.35) # can't ask google for these too fast...
}

# keep only ones near chicago...
df2 <- subset(df, lat > 41.62 & lat < 42.05 & lng > -87.96 & lng < -87.5 
              & !is.na(lat) & !is.na(lng))

# quick ggplot plot of data
ggplot(df2) + geom_point(aes(x=lng, y=lat))

# do points overlayed on openstreetmap
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

  
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), panel.margin=element_blank(),
        plot.margin=unit(c(0,0,0,0), "cm"))

#430w x 415h
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
