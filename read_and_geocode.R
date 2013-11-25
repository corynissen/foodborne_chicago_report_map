
#############################################################################
# This file reads in the csv file from the foodborne chicago admin page
# and uses an online geocoding service to get lat-lng data from the 
# restaurant address.
# Business license code from Chicago data portal: http://goo.gl/kq2OP
#############################################################################

library(RCurl)
library(RJSONIO)
library(ggmap)

df <- read.csv("submissions-2013-11-05.csv", stringsAsFactors=F)
names(df) <- tolower(names(df))
# order by id, or basically date
df <- df[order(df$id),]

df$lat <- df$lng <- rep(NA, nrow(df))
# do this in a loop since we have to sleep to avoid google's rate limiting
for(i in 1:nrow(df)){
  rest.address <- ifelse(grepl("chicago", df$restaurant.address[i], 
                               ignore.case=T), df$restaurant.address[i],
                         paste0(df$restaurant.address[i], ", Chicago IL"))  
  results <- geocode(rest.address)
  df$lng[i] <- results$lon
  df$lat[i] <- results$lat
  Sys.sleep(.35) # can't ask google for these too fast...
}

# look at where the business licenses are...
# 17mb, takes a minute or two to download this way
# luckily for us, Chicago has already geocoded these
lic <- read.csv("http://data.cityofchicago.org/views/uupf-x98q/rows.csv",
                        stringsAsFactors = F) 
names(lic) <- tolower(names(lic))
# let's worry about just the food places...
lic <- subset(lic, license.description %in% c("Retail Food Establishment", 
              "Retail Food Est.-Supplemental License for Dog-Friendly Areas",
              "Tavern"))
# some aren't geocoded... just remove them for now
lic <- subset(lic, !is.na(latitude) | !is.na(longitude))
