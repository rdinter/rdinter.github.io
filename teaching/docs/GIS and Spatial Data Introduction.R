##### GIS and Spatial Data Introduction


rm(list=ls())       #Remove all data in the R enviroment
temp <- tempdir()
setwd(temp)   #Set working directory
library(maptools)
library(rgeos)
library(rgdal)

#Now download the data from: http://dds.cr.usgs.gov/pub/data/nationalatlas/countyp020_nt00009.tar.gz
#You can also reach this by going here: http://www.nationalatlas.gov/maplayers.html
#Select 'County and Equivalent (Current)'
#Extract to your working directory

#This code will download the files directly to your working directory
url <- 'http://dds.cr.usgs.gov/pub/data/nationalatlas/countyp020_nt00009.tar.gz'
file <- basename(url)
download.file(url, file)
untar(file, exdir = temp )
USA <- readShapeSpatial('countyp020')

class(USA)  #this should tell you that the shape file is a SpatialPolygonsDataFrame

#str(USA)   #DO NOT RUN! Well, run it if you want to see how much information is in
           #a SpatialPolygonsDataFrame. Just trust me though, it is a lot.

str(as.data.frame(USA))
str(USA@data)   #It is faster to access the data portion of your SPDF with the @data
head(USA@data)
dim(USA@data)

#Clearly we do not need the entire USA, one way to simplify this is to subset our data based on FIPS
#To learn more about FIPS go here: http://quickfacts.census.gov/qfd/meta/long_fips.htm
USA$FIPS <- as.numeric(levels(USA$FIPS))[USA$FIPS] #FIPS is currently a factor and we convert it to numeric
USA <- subset(USA, subset= FIPS < 57000)           #This subsets to all counties in the USA 50 states
USA <- subset(USA, subset = !(STATE %in% c('AK','HI'))) #Remove Alaska and Hawaii

#Let's get some data!
url <- 'http://www4.ncsu.edu/~rdinter/docs/ruralurbancodes2003.csv'
file <- basename(url)
download.file(url, file)
url <- 'http://www4.ncsu.edu/~rdinter/docs/BBLoans.csv'
file <- basename(url)
download.file(url, file)

data <- read.csv("ruralurbancodes2003.csv", header=T) #metro is coded 1, 2, or 3
loan <- read.csv("BBLoans.csv", header=T) #from a project on broadband loans
                                          #Two types of loans, the pilot program
                                          #and current.

data <- merge(x=data, y = loan, by.x="FIPS.Code", by.y="county_fips",all.x=T)
data$dbbloan[is.na(data$dbbloan)]         <- 0
data$dpilotbbloan[is.na(data$dpilotbbloan)] <- 0
rm(loan)

NC <- subset(USA, subset = FIPS > 36999 & FIPS < 38000) #North Carolina has the state fips code of 37
plot(NC)                                                #We can see North Carolina here
plot(NC[NC$FIPS==37095,])  #Why Hello, Hyde County North Carolina
sum(NC$FIPS == 37095)      #http://en.wikipedia.org/wiki/Hyde_County,_North_Carolina

#Well, shit. Our dataframe is all screwy because apparently Hyde County is 10x more
#important than the average county. Let's wrap this back together.
usa <- unionSpatialPolygons(USA,USA$FIPS)
j5 <- USA['FIPS']
j5 <- as.data.frame(j5[!duplicated(j5$FIPS),])
usa <- SpatialPolygonsDataFrame(usa,j5,match.ID=F)
rm(USA,j5)

#The unionSpatialPolygons function will combine the different polygons floating
#around into one polygon per county.
names(usa)
row.names(usa)[1:10] #the row names of the data are the associated FIPS
usa$FIPS        <- row.names(usa) #correct for the FIPS variable not aligning with obs.

#Select our data to put in our spatial dataframe
row.names(data) <- data$FIPS.Code
usa@data        <- data.frame(usa@data,
                              data[match(as.numeric(usa$FIPS), data$FIPS.Code),])
check <- as.numeric(usa$FIPS) %in% data$FIPS.Code #logical operator that indicates
                                                  #whether the first element is in the
                                                  #set of the second element
sum(check) #should be the same as the observations in data
sum(!check) #indicates missing FIPS codes
usa@data[!check,]


plot(usa,lwd=0.025)
plot(usa[which(usa$dpilotbbloan==1),],lwd=0.05,col="yellow",add=TRUE)
plot(usa[which(usa$dbbloan==1),],lwd=0.05,col="blue",add=TRUE)
plot(usa[which(usa$X2003.Rural.urban.Continuum.Code < 4),],
     lwd=0.05,col="red",add=TRUE)
plot(usa[which(usa$X2003.Rural.urban.Continuum.Code < 4 & usa$dbbloan==1),],
     lwd=0.05,col="purple",add=TRUE)
plot(usa[which(usa$X2003.Rural.urban.Continuum.Code < 4 & usa$dpilotbbloan==1),],
     lwd=0.05,col="orange",add=TRUE)
legend('bottomleft',legend=c('Metro','Metro/Pilot','Metro/Current','Pilot', 'Current'),
       col=c('red','orange','purple','yellow', 'blue'), lty=1, lwd = 3, cex=.5)
title(main='Relation of Metro to Broadband Loans')

#############
#USE COORDS AS A WAY TO PICK THE CENTER OF THE COUNTY
#TAKE OUT THE COUNTY LINES BUT KEEP THEM FOR METRO STATUS (or grey them)

plot(usa,lwd=0.025)
plot(usa[which(usa$X2003.Rural.urban.Continuum.Code < 4),],lwd=0.05,col="red",add=TRUE)
points(coordinates(usa[which(usa$dbbloan==1),]),col="green", pch=17, lwd=0.05)
points(coordinates(usa[which(usa$dpilotbbloan==1),]),col="blue", pch=16, lwd=0.05)
legend('bottomleft',bty='n',legend=c('Metro County','Pilot Loan','Current Loan'), col=c('red','blue','green'), pch=c(15,16,17))
title(main='Relation of Metro to Broadband Loans')

