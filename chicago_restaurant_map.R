
#############################################################################
# This file creates a map of the restaurants in Chicago using the 
# Chicago data portal business license data set as the source data
#############################################################################

library(ggplot2)
library(ggmap)
library(rgdal)

# shape files for Chicago...
shapefile <- readOGR("chicago_city_shapefiles", "City_Boundary")
shapefile.converted <- spTransform(shapefile, CRS("+proj=longlat +datum=WGS84"))

# the placenames are a distraction here...
r1 <- qmap("chicago", darken=.1) + 
  geom_point(data=lic, aes(x=longitude, y=latitude), alpha=.2) +
  coord_cartesian(xlim=c(-87.96, -87.5), ylim=c(41.62, 42.05))
ggsave(plot=r1, "chi_restaurants.png", height=6, width=6)

# let's try the cloudmade one without placenames...
cloudmadekey <- scan("~/cn/personal/keys/cloudmadekey.txt", what="character")
r2 <- qmap("chicago", source="cloudmade", api_key=cloudmadekey, maptype=108995)+
  geom_polygon(aes(x = long, y = lat, group=group), alpha=.2, fill="black", 
               data = shapefile.converted) +
  geom_point(data=lic, aes(x=longitude, y=latitude), alpha=.3, size=1.1) +
  coord_cartesian(xlim=c(-87.96, -87.5), ylim=c(41.62, 42.05))
ggsave(plot=r2, "chi_restaurants2.png", height=6, width=6)
