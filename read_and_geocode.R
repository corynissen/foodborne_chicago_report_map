
#############################################################################
# This file reads in the csv file from the foodborne chicago admin page
# and uses an online geocoding service to get lat-lng data from the 
# restaurant address.
#############################################################################
library(RCurl)
library(RJSONIO)

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
      df$geocode[i] <-geocode.list$results[1]
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
