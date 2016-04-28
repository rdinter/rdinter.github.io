##### Displaying Spatial Data


rm(list=ls())       #Remove all data in the R enviroment
temp <- tempdir()
setwd(temp)   #Set working directory
library(maptools)
library(rgeos)
library(rgdal)


#This code will download the files directly to your working directory
url <- 'http://dds.cr.usgs.gov/pub/data/nationalatlas/countyp020_nt00009.tar.gz'
file <- basename(url)
download.file(url, file)
untar(file, exdir = temp )
USA <- readOGR(temp,'countyp020',p4s="+proj=longlat") #notice this is different from last time
#and defined a projection
USA$FIPS <- as.numeric(levels(USA$FIPS))[USA$FIPS] #FIPS is currently a factor and we convert it to numeric
USA <- subset(USA, subset= FIPS < 57000)           #This subsets to all counties in the USA 50 states
USA <- subset(USA, subset = !(STATE %in% c('AK','HI'))) #Remove Alaska and Hawaii

states <- subset(USA, subset =  (FIPS - as.numeric(as.character(STATE_FIPS))*1000 !=0)) #remove lakes
states <- unionSpatialPolygons(states,states$STATE)
STATE = names(states)
states <- SpatialPolygonsDataFrame(states,as.data.frame(STATE),match.ID=F)

###### Projections
#http://www.remotesensing.org/geotiff/proj_list/
aeqd.proj = '+proj=aeqd  +lat_0=37.5 +lon_0=-120 +x_0=0 +y_0=0'
#     http://www.remotesensing.org/geotiff/proj_list/azimuthal_equidistant.html
#     +proj=aeqd  +lat_0=Latitude at projection center 
#                 +lon_0=Longitude at projection center
#                 +x_0=False Easting
#                 +y_0=False Northing
j5 = spTransform(states,CRS(aeqd.proj))
plot(j5)
title(main = 'Azimuthal Equidistant')

eqdc.proj = '+proj=eqdc  +lat_1=-10 +lat_2=50 +lat_0=20 +lon_0=-100 +x_0=0 +y_0=0'
#     http://www.remotesensing.org/geotiff/proj_list/equidistant_conic.html
#     +proj=eqdc  +lat_1=Latitude of first standard parallel
#                 +lat_2=Latitude of second standard parallel
#                 +lat_0=Latitude of center 
#                 +lon_0=Longitude of center
#                 +x_0=False Origin Easting
#                 +y_0=False Origin Northing
j5 = spTransform(states,CRS(eqdc.proj))
plot(j5)
title(main = 'Equidistant Conic')

aea.proj = '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-100
+x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m'
#     http://www.remotesensing.org/geotiff/proj_list/albers_equal_area_conic.html
#     +proj=aea   +lat_1=Latitude of first standard parallel
#                 +lat_2=Latitude of second standard parallel
#                 +lat_0=Latitude of false origin 
#                 +lon_0=Longitude of false origin
#                 +x_0=Easting of false origin
#                 +y_0=Northing of false origin
j5 = spTransform(states,CRS(aea.proj))
plot(j5)
title(main = 'Albers Equal Area')

robin.proj = '+proj=robin +lon_0=-110 +x_0=0 +y_0=0'
#       http://www.remotesensing.org/geotiff/proj_list/robinson.html
#       +proj=robin +lon_0=Longitude at projection center
#                   +x_0=False Easting
#                   +y_0=False Northing
j5 = spTransform(states,CRS(robin.proj))
plot(j5)
title(main = 'Robinson')

NC = subset(USA, STATE=='NC')
NC <- unionSpatialPolygons(NC,NC$FIPS)
FIPS = names(NC)
NC <- SpatialPolygonsDataFrame(NC,as.data.frame(FIPS),match.ID=F)


# Grab some Spatial Point Data
url <- 'ftp://ftp.nconemap.com/outgoing/vector/swlg.zip'
file <- basename(url)
download.file(url,file)
unzip(file, exdir = temp )
hogs <- readOGR(temp,'swlg') #notice this is different from last time
summary(hogs)
plot(hogs)
plot(NC, add=T) #Hey, NC didn't plot. Well of course not, the projections are different.

robin.proj = '+proj=robin +lon_0=-80 +x_0=0 +y_0=0 +units=m'
NC = spTransform(NC,CRS(robin.proj))
hogs = spTransform(hogs,CRS(robin.proj))
plot(NC)
points(hogs, pch=20, cex=.5) #we could have also done plot(hogs,add=T)
#check some plot options here: http://www.cookbook-r.com/Graphs/Shapes_and_line_types/

##### Calculate the Centroid for each County
NC.centroid <- gCentroid(NC, byid=T)
plot(NC)
points(NC.centroid, pch=21, bg='red')

#Another method:
points(coordinates(NC), pch=24, bg='blue')

# Calculate distance, this will depend on your projection.
dhogs <- matrix(0,nrow=length(hogs),ncol=length(NC.centroid))
colnames(dhogs) = row.names(NC.centroid)
for (i in row.names(NC.centroid)){
  dhogs[,i] = t(spDistsN1(hogs,NC.centroid[i,]))
}

dhogs1 <- gDistance(NC.centroid, hogs, byid=T)

#Another way
library(fields)
dhogs2 <- rdist(coordinates(hogs),coordinates(NC.centroid))
dhogs3 <- rdist.earth(coordinates(hogs),coordinates(NC.centroid),miles=F)

#Find minimum
min   = apply(dhogs,2,min)
max   = apply(dhogs,2,max)

##### Spatial Lines for more sophisticated distance calculation
url = 'http://www4.ncsu.edu/~rdinter/docs/NChighway.zip'
file <- basename(url)
download.file(url, file)
unzip(file, exdir = temp )
road <- readOGR(temp,'NChighway') #notice this is different from last time
road = spTransform(road,CRS(robin.proj))

shortest.dists <- numeric(nrow(hogs))
for (i in seq_len(nrow(hogs))) {
  shortest.dists[i] <- gDistance(hogs[i,], road)
}

#### Counting Points in Polygons
hogf = over(hogs,NC) #Attaches the Polygon ID for each farm
table(hogf)
NC$hogf = as.numeric(table(hogf))

#### Using Google for KML files
url <- 'http://www4.ncsu.edu/~rdinter/docs/Biscuitville%20NC.kml'
file <- basename(url)
download.file(url, file)
bville = readOGR(file, 'Locations')
bville = spTransform(bville,CRS(robin.proj))
plot(NC)
points(bville)

#Distance to Biscuitville
library(ggmap)
mapdist('Raleigh','Durham')
mapdist('Raleigh','Durham',mode='bicycling')

dbville = data.frame()
for (i in row.names(bville)){
  dbville = rbind(dbville,mapdist('Raleigh',coordinates(bville[i,])[1:2]))
}
dbville

#### Using spplot
spplot(NC, zcol='hogf')

#Now some options to make this better
library(RColorBrewer)
display.brewer.all()

terrain = function(x)rev(terrain.colors(x)) #This is a colorwheel that is reverse of
heat = function(x)rev(heat.colors(x))       #what has been prespecified

spplot(NC, #dataset
       zcol='hogf',                    #variable to be plotted
       col.regions = heat(100),        #the color scale to be used, 100 stands for the
       #number of shades to be used in plotting.
       col = 'gray',                   #this is the color of the county borders
       colorkey = list(space='bottom', #where the scale is located, can also be top, right, left
                       width=1),
       main='Hog Farm Prevalence',     #main title of the plot
       sp.layout=list('sp.lines',      #adding on another layer to the plot, type of layer
                      road,            #data for the layer
                      col='blue',      #color of the layer
                      alpha=0.5)       #transparency setting
)
#Or if you want to have this as 5 classes
hist(NC$hogf)
table(NC$hogf)
breaks = c(0,5,15,30,50,100,250,912)
spplot(NC,'hogf',at=breaks,col.regions=terrain(length(breaks)-1))

qcut <- function(x, n) {
  q = unique(quantile(x, seq(0, 1, length = n + 1),na.rm=T))
  n = length(q)-1
  out = cut(x, q, labels = seq_len(n),include.lowest = TRUE,na.rm=T)
  out
}
NC$temp = qcut(NC$hogf,5)
spplot(NC,zcol='temp')

#### ggmap
ghogs = spTransform(hogs,CRS('+proj=longlat'))
ghogs = as.data.frame(ghogs@coords)
names(ghogs) <- c('lon','lat')
qmplot(lon, lat, data=ghogs, colour = I('red'), size = I(3), darken = .3, alpha=.3)
qmplot(lon, lat, data=ghogs, colour = I('red'), size = I(3), darken = .3, source='osm')
