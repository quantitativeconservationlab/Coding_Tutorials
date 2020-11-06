################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 

# The following will walk you through an example of how to perform a basic data
# workflow to process species, habitat, climate, and spatial data for the use in 
# downstream spatial analyses.
# Prior to starting the tutorial, please review Chapter 2 from the online tutorial
# located at: https://geocompr.robinlovelace.net/spatial-class.html
################################################################################

# Initial preparation #################################

# Clear your work space and release your computer's memory.
rm( list = ls() )
gc()

# Install and load the required packages.
install.packages( "dplyr" )
install.packages( "ggplot2" )
install.packages( "tidyr" )
install.packages( "tidyverse" ) # Tidyverse includes "dplyr", "tidyr", and "ggplot2" and others
install.packages( "lubridate" )
install.packages( "sp" )
install.packages( "sf" )
install.packages( "rgdal" )
install.packages( "rgeos" )
install.packages( "maptools" )
install.packages( "raster" )
install.packages( "rasterVis" )
install.packages( "prism" )
install.packages( "psych" ) 

library(dplyr) # Combines data frames
# Set global dplyr option to see all columns and more than 10 rows
options( dplyr.width = Inf, dplyr.print_min = 100 )

library(tidyr) # Spread and other data frame functions
library(ggplot2) # Fancy publication-quality plots
library(lubridate) # Easy date adjustments and calculations
library(sp)
library(sf)
library(rgdal) # Imports projects and transforms spatial data. Requires the "sp" package.
library(rgeos) # Spatial manipulation functions i.e. buffer and interpolate
library(maptools) # Reads and manipulates ESRI shape files
library(raster) # Manipulates raster objects
library(rasterVis) # Visualizes rasters
library(prism) # Extracts climate data from PRISM
library(psych)

# Set your working directory.
# In our case we use the current directory, but you should adjust this to wherever 
# you have your code and data.
getwd()
setwd() # If adjustment is needed.

# Create an object containing the working directory's Path.
workdir <- getwd()

# Create an object containing your "Data" directory's Path.
datadir <- paste(workdir, "/Data/", sep = "")

# Importing and checking species data #################################

# The .csv file "sppdata.csv" contains presence/absence observations and eastings 
# and northings for different site locations.
# The species data comes from the latest Wisconsin Bird Atlas (2016-2017):
# http://www.uwgb.edu/birds/wbba/index.htm 

# In this tutorial we will be working with the Hermit Thrush data ("heth"). 
# Data for the Eastern Meadowlark ("eame") is also available for you to practice 
# on your own. 

# Import these data into R using the read.csv() function and defining the path to the file.
spp_df <- read.csv( file = paste( datadir, "sppdata.csv", sep = "" ), # Specifies the data file name
                    header = TRUE, # Keeps column labels
                    strip.white =TRUE ) # Removes white spaces 
# The paste() function was used to combine the Paths of your working directory 
# with the path to the data file.

# Check that the data were imported the way you wanted it (i.e. no empty rows or columns). 
glimpse( spp_df )

# View first and last rows of the data frame.
head( spp_df ); tail( spp_df )
# The semicolon allows you to run two separate functions on the same line and view 
# both outputs in the Console pane.

# Check the structure of the data frame and adjust variable classes as needed. 
str(spp_df)

spp_df$id <- as.character(spp_df$id)
spp_df$Year <- as.factor(spp_df$Year)

# For these data, "id" represents the name of a site where presence/absence
# data were collected.
# "x" and "y" represent the coordinates of the site.
# The values in "eame" reflect whether the bird was present (1) or absent (0)
# at the site.

# How many presences and absences were observed?
table( spp_df$heth )
# What does this tell you about your sample size?

# View spatial distribution of your observations using the "ggplot2" package.
ggplot( data = spp_df, aes( x, y, color = factor( heth ) ) ) + geom_point() + theme_bw()
# What can you see regarding the observed spatial distribution for this species?
# What does it tell you about the bird's ecology? 
# What other checks do you need to make for your own data? 
# Is the sampling biased? 

# "x" and "y" represent GPS coordinates defined by a specific Coordinate Reference System (CRS).
# You should always know and assign the appropriate CRS used when collecting spatial data.
# An easy way to define coordinate reference systems is by using their EPSG code. 
# You can find a searchable list of codes at: http://www.spatialreference.org 
# See https://geocompr.robinlovelace.net/spatial-class.html#crs-intro for more info.

# For these data, site locations were recorded using NAD_1983_HARN_Wisconsin_TM. 
# We use this to define our coordinate system.
siteproj <- sp::CRS(  "+init=epsg:3071" )
# This creates a CRS class object containing the parameters of the CRS.
# Note that we specify which package the function comes from using a double-colon. 
# This is often good practice. 

# Define site locations by extracting eastings and northings from the data frame 
# and converting them to spatial points using the correct CRS. 
sites <- sp::SpatialPoints( spp_df[, c( "x", "y" ) ], proj4string = siteproj )
# This creates a SpatialPoints class object containing the coordinates for each
# point and the CRS parameters.

# View attributes and first rows.
class( sites ); head( sites )

# Check if your sites are within your study area polygon. 
plot( sites )
# Are they within your study region? 
# Caution: Mistakes are common when transcribing x, y locations.

# Processing shape files and producing background points #################################

# In this section, we will be downloading climate and habitat data sets that span 
# the most of the United States.
# However, the species data we imported were collected from sites within the state
# of Wisconsin.
# Therefore, we need to identify and define a set of parameters that isolate
# Wisconsin data from the larger data sets.

# First, lets import a shape file (.shp) of Wisconsin. 
# Importing a shape file with the "rgdal" package also imports its projection. 
# You can also import shapefiles using maptools without projections. 

# Import Wisconsin shapefile including its projection using the readOGR() function.
WI <- rgdal::readOGR( paste( datadir, "Wi_State_Outline/WI_state_outline.shp", sep="" ) )
# This creates a Spatial Polygons Data Frame class object.
# For this function to work, you need the .shp file and the other associated files 
# located in the Path.

# View the file details.
summary( WI )
# What do you think the "min" and "max" values represent in the "Coordinates:" tab?

# Make a quick plot.
plot( WI )

# Check if projection matches site location data.
proj4string( WI )

# Convert projection so that it does match:
WI <- sp::spTransform( WI, proj4string( sites ) )

# Note: A common mistake when working with spatial data is forgetting to match their 
# projections.
# It is particularly common when you are sourcing your data from multiple locations. 
# This can introduce significant errors in your analysis. 

# Our data set contains presence/absence records, but we will also compare 
# these analyses with those using presence/background data. 
# We thus generate random background random points and keep them separate from our original 
# data set.
# We will generate the same number of background points as presence observations

# Number of presence observations for hermit thrush.
M <- table( spp_df$heth )[2]
# What does the "[2]" do?

# Generate background points within Wisconsin using a random sampling scheme.
bkgrd.pnts <- sp::spsample( WI, n = M, type = 'random' )
# This creates a SpatialPoints class object containing the coordinates for the 
# random points and the CRS parameters.

# View
bkgrd.pnts 

# Plot results
points( bkgrd.pnts@coords )
# Was this a reasonable number of background points? 
# What sampling scheme would you use for your own data? 
# More ideas on how to choose background points can be found in: 
# Jarnevich et al. (2017) Minimizing effects of methodological decisions on interpretation and 
# prediction in species distribution studies: An example with background selection. 
# Ecological Modelling, 363, 48-56. 
  
# Create background points data frame.
bkgrd.pnts_df <- data.frame(bkgrd.pnts@coords)
bkgrd.pnts_df$id <- rownames(bkgrd.pnts_df)

# Downloading climate data #################################

# In this section, we will download climate data from the PRISM Climate Group database. 
# Specifically, we will process data for minimum temperatures and precipitation
# during the Hermit Thrush breeding season (June - July).
# In addition, the data we will download contains information for the lower 48 states
# of the USA across 30 years at a resolution of 800m.
# We will use the parameters we identified in the previous section to subset these
# data sets for only data collected in Wisconsin.

# Set path where you want to store the downloaded data. 
# In our case we use the data subfolder within our R project's directory, 
# but you should adjust this to wherever you want to store your data.
# The paste function combines two character objects.
datadir <- paste( workdir, # Path to our data directory
                  "/Data/", # Path extension to our "Data" subdirectory
                  sep = "") # Joins the two Paths with no spaces
# "datadir" is a character object containing the Path to the "Data" subfolder.
# Assigning directories this way helps to automate data handling and eliminate manual 
# transfer of data files. 

# Download the minimum temperature normals data.
# Define the new downloaded file name and Path.
mintfiles <- paste( datadir, "PRISM_Jun-Jul_minT_30yrnorm", sep = "" )

# Set "mintfiles" as the "global" Path to deposit data downloaded by the "prism" package.
options( prism.path = mintfiles )

# Download minimum temperature (tmin) normals data for June and July.
get_prism_normals( type = "tmin", # Defines the type of PRISM data to download (minimum temperature) 
                   resolution = "800m", # Sets the resolution of the data
                   mon = 6:7 ) # Designates the numeric month(s) of the data you 
                               # want to download (June (6), July (7)).

# Look in your "Data" subdirectory.
# You should see a new folder named "PRISM_Jun-Jul_minT_30yrnorm" containing the 
# data downloaded from PRISM.
# Within the folder, there are two additional folders called "PRISM_tmin_30yr_normal_800mM2_06_bil" 
# and "PRISM_tmin_30yr_normal_800mM2_07_bil".
# The folder with "06" contains data for June and "07" for July.
# These folders contain many different kinds of data files (.bil, .xml, .hdr, .txt, 
# .prj, .csv, .stx).

# Look at the downloaded prism files product names.
head( ls_prism_data( name = TRUE) )

# Look the the absolute Path for these files.
head( ls_prism_data( absPath = TRUE), 30 )

# Next, download the rainfall normals (ppt) for June and July.
# See if you can write your own code to download these data and deposit them in a new 
# subdirectory named "PRISM_Jun-Jul_rain_30yrnorm" in your project's "Data" folder.

# Define the new downloaded file name and Path.
rainfiles <- paste( datadir, "PRISM_Jun-Jul_rain_30yrnorm", sep = "" )

# Set "mintfiles" as the "global" Path to deposit data downloaded by the "prism" package.
options( prism.path = rainfiles )

# Download precipitation (ppt) normals data for June and July.
get_prism_normals( type = "ppt", resolution = "800m", mon = 6:7 )
# Double-check that these data were downloaded into your "Data" subdirectory.

# Look at the downloaded prism files product names.
head( ls_prism_data( name = TRUE) )

# Look the the aboslute Path for these files.
head( ls_prism_data( absPath = TRUE), 30 )


# Preparing climate data #################################

# Minimum temperature and precipitation normals data for June and July are saved in 
# our "Data" subdirectory.
# We will need to subset these to only include information for Wisconsin.
# We will prepare the minimum temperature and precipitation normals data separately 
# prior to coalescing them with our other data.
# These steps involve combining data from June and July, calculating mean values, 
# and subsetting the processed data.
# We will be primarily with "raster" class objects.
# Please see the following link for more information on raster data: 
# https://geocompr.robinlovelace.net/spatial-class.html#raster-data

# Minimum temperature normals:

# Set path of PRISM data you want to manipulate.
options( prism.path = mintfiles )

# "Stack" the minimum temperature data files (June and July).
# This will stack the different file types into a combined "raster" object in R.
MinTAll <- prism_stack( ls_prism_data()[, 1] )
# The square brackets indicate indexing.
# This line keeps all rows from the first column of ls_prism_data().
# Are there other indexing parameters that would produce the same result?
# What if you only wanted to work with the data from July?

# Assess the dimensions of the raster stack.
dim( MinTAll )
# The output is presented as rows, columns, layers.

str( MinTAll )

# Click on "MinTALL" in the Data pane (or: View (MinTALL) ).
# "MinTALL" is a "RasterStack" object with 2 "layers" consisting of the PRISM data 
# for June and July.

# Use the "raster" package to process raster objects.
# Convert the coordinate reference system (crs) of the raster object to the same one 
# used with our species data.
MinTWI <- raster::projectRaster( MinTAll, crs = proj4string( sites ) )

# Assess the dimensions of the "RasterBrick" object.
dim( MinTWI )
# Why were more rows and columns added? 

# Crop the raster brick to only include Wisconsin location data.
MinTWI <- raster::crop( MinTWI, WI )
dim( MinTWI )
# Note how the dimensions are much smaller.

# Calculate the seasonal mean of minimum temperature normals for the breeding season 
# (Jun-Jul).
# This will combine both layers of data into one layer containing the mean values.
MinT <- stackApply( MinTWI, 1:1, fun = mean ) 
# 1:1 assigns the same index to both files so we get the combined seasonal mean.
# The RasterBrick has been converted to a "RasterLayer" object.

dim(MinT)
# The object now has only 1 layer.

# Label the resulting column.
names( MinT ) <- c( "minT" )
names( MinT )

# Save the cropped raster as a GTiff (.tif) file using the writeRaster() function.
writeRaster( MinT, filename = paste( datadir, "/MinT.tif", sep = "" ), 
             format = "GTiff" )

# Plot seasonal (Jun-Jul) mean for minimum temperature 30yr normals.
rasterVis::levelplot( MinT )  + latticeExtra::layer( sp.polygons( WI, col = 'white', lwd = 2 ) )
# Plot construction may take several minutes to complete.  
# Why do you think our plot contains data that falls outside of Wisconsin's borders?

# Remove intermediate large rasters produced during the workflow.
rm( "MinTAll", "MinTWI" )

# Now that we have seasonal data for Wisconsin we need to match them to our site locations. 
# Extract values for each site location.
minTvals <- raster::extract( MinT, sites )

# Double-check that each site has an associated value.
head( minTvals ); length( minTvals )

# Extract value for each background location.
minTvals.bkgrd <- raster::extract( MinT, bkgrd.pnts )

# Double-check that each site has an associated value.
head( minTvals.bkgrd ); length( minTvals.bkgrd )


# Rainfall normals:
  
# Set path of PRISM data you want to manipulate.
options( prism.path = rainfiles )
  
# Stack all files extracted (for Jun-Jul):
RainAll <- prism_stack( ls_prism_data()[ , 1 ] )
  
# Convert the CRS of the raster object to the same one 
# used with our species data.
RainWI <- raster::projectRaster( RainAll, crs = proj4string( sites ) )

# Assess the dimensions of the raster brick.
dim( RainWI )

# Crop the raster brick to only include Wisconsin location data.
RainWI <- raster::crop( RainWI, WI ) 

dim( RainWI )
  
# Get seasonal mean of rainfall normals for the breeding season (Jun-Jul):
Rain <- stackApply( RainWI, 1:1, fun = mean )
dim( Rain )  

# Label resulting column:
names( Rain ) <- c( "rain" )

# Save the cropped raster as a GTiff (.tif) file using the writeRaster() function.
writeRaster( Rain, filename = paste( datadir, "Rain.tif", sep = "" ), 
             format = "GTiff" )

# Plot seasonal (Jun-Jul) mean for precipitation normals.
rasterVis::levelplot( Rain )  + latticeExtra::layer( sp.polygons( WI, col = 'white', lwd = 2 ) )

# Remove intermediate large rasters produced during the workflow.
rm( "RainAll", "RainWI" )

# Now that we have seasonal data for Wisconsin we need to match them to our site locations. 
# Extract values for each site location.
rainvals <- raster::extract( Rain, sites )

# Double-check that each site has an associated value.
head( rainvals ); length( rainvals )

# Extract value for each background location.
rainvals.bkgrd <- raster::extract( Rain, bkgrd.pnts )

# Double-check that each site has an associated value.
head( rainvals.bkgrd ); length( rainvals.bkgrd )

# Manually create a subdirectory "Workspaces" and save the workspace.
save.image( "Workspaces/Save1.RData" )
load( "Workspaces/Save1.RData" )


# Manipulating landcover data #################################

# We use landcover data from the National Geospatial Data Asset (NGDA).
# https://www.mrlc.gov/nlcd01_data.php 
# We downloaded data directly from the website and extracted them into our Data folder.
# We are interested in land cover surrounding our sites only. 
# We import the complete file first and then extract land cover values around our sites (using a buffer). 
# We do this by adapting code from http://mbjoseph.github.io/2014/11/08/nlcd.html 

# Set path to habitat layer .img file.
habpath <- paste( datadir, "NLCD_LandCover_2016/NLCD_2016_Land_Cover_L48_20190424.img", sep = "" )

# Import .img file as a raster file using the "raster" package.
habrast <- raster::raster( habpath )

# Check the data by making a basic plot.
plot( habrast )

# Convert CRS of sites and background points to match habrast.
sites_transf <- spTransform( sites, proj4string( habrast) )

bkgrd.pnts_transf <- spTransform( bkgrd.pnts, proj4string( habrast ) )

# Import the legend for the 2016 NLCD data.
nlcdlegend <- read.csv( paste( datadir, "NLCD_LandCover_2016/NLCD_Land_Cover_Legend.csv", sep = "") )

# View the legend.
head( nlcdlegend,15 )

# What are the possible habitat types?
unique( nlcdlegend$Legend )

# Create a function that summarizes the proportion of each cover type 
# for each site.

# Required inputs:
# lcraster = nlcd habitat raster object ("habrast")
# nlcdlegend = nlcd legend ("nlcdlegend")
# sites = spatial points of study sites
# siteid = unique transect ids where we extract habitat (spp_df$id)
# buf = buffer radius size in meters over which we extract habitat
# if set to NULL then habitat is extracted at the point (no buffer)

# Output:
# Data frame with proportions of habitats found within buffer area 
# surrounding study sites.
# When are functions useful? Why create them?

summarize_landcover <- function( lcraster, nlcdlegend, sites, siteid, buf = NULL ){
 
  # Convert transect location projection to match NLCD data projection.
  temp.points <- spTransform( sites, proj4string( lcraster ) )
  
  # Extract land cover data at each site within specified buffer. 
  Landcover <- raster::extract( lcraster, temp.points, buffer = buf )
  
  # Summarize land cover as a proportion for each site.
  summ <- lapply( Landcover, function( x ) prop.table( table( x ) ) )
  
# Extract habitats found at our sites
num.codes <- unique( unlist( Landcover ) )

# Create reduced legend based on habitats present at our sites
upd.lgnd <- nlcdlegend %>% dplyr::filter( Value %in% num.codes )  

# View updated legend.
print( upd.lgnd )

# Summarize results in a data frame:
lcdf <- data.frame( id = rep( siteid, lapply( summ, length ) ),
                    cover.id = factor( names( unlist( summ ) ) ),
                    proportion = unlist( summ ) )

# Add name column to data frame.
lcdf$cover.lab <- lcdf$cover.id

# Match factor levels. 
levels( lcdf$cover.lab ) <- as.character( upd.lgnd$Legend[upd.lgnd$Value %in% levels(lcdf$cover.id)] )

# View
print( levels( lcdf$cover.lab ) )

# Delete any intermediate files created by raster.
raster::removeTmpFiles()

# Output data frame.
return ( lcdf )

}

habdf <- summarize_landcover(lcraster = habrast, nlcdlegend = nlcdlegend, sites = sites_transf, siteid = spp_df$id, buf = 35)

# View the output of the function.
head( habdf ); dim( habdf )
table( habdf$cover.lab )

#plot histograms of habitat types found at our transects
ggplot( habdf, aes( x = proportion *100 ) ) + 
  theme_classic() + 
  xlab( "Habitat (%)" ) +
  geom_histogram( position = "identity", alpha = 0.5,
                  bins = 5 ) + 
  facet_wrap( ~cover.lab, scales = "free_y" )

# Transform data frame from long to wide format to append to transects.
hab.wide <- habdf %>% dplyr::select( -cover.id )%>%
  #convert to wide format
  tidyr::spread( key = cover.lab, value = proportion, fill = 0 )

# Double-check that data was transformed correctly.
head( hab.wide ); dim( hab.wide )

# How many entries did we have for each habitat?
colSums( hab.wide!=0 )

# Join with transects so that we can plot it spatially.
# Make sure each of the data frames have a shared variable.

hab.wide <- left_join( hab.wide, spp_df, 
                       by = "id")
head( hab.wide )


# If we want to alter the land cover categories: 
# The more categories you use, the more data you require. 
# Think whether you can combine some prior to your analysis. 
# Potential combined categories:
cover_df <- hab.wide %>% rowwise() %>% #add new columns for combined landc over categories:
dplyr::mutate( Other = sum( `Open Water`,`Barren Land`,
                            `Evergreen Forest`, `Mixed Forest`, na.rm = TRUE ) )
cover_df <- data.frame( cover_df )

# View the new data frame.
head( cover_df )
colSums( cover_df !=0)

# Repeat for the background points.

bkgrddf <- summarize_landcover(lcraster = habrast, nlcdlegend = nlcdlegend, sites = bkgrd.pnts_transf, siteid = bkgrd.pnts_df$id, buf = 35)

# View the output of the function.
head( bkgrddf ); dim( bkgrddf )
table( bkgrddf$cover.lab )

#plot histograms of habitat types found at our transects
ggplot( bkgrddf, aes( x = proportion *100 ) ) + 
  theme_classic() + 
  xlab( "Habitat (%)" ) +
  geom_histogram( position = "identity", alpha = 0.5,
                  bins = 5 ) + 
  facet_wrap( ~cover.lab, scales = "free_y" )

# Transform data frame from long to wide format to append to transects.
bkgrd.wide <- bkgrddf %>% dplyr::select( -cover.id )%>%
# Convert data frame from long to wide format.
  tidyr::spread( key = cover.lab, value = proportion, fill = 0 )

# Double-check that data was transformed correctly.
head( bkgrd.wide ); dim( bkgrd.wide )

# How many entries did we have for each habitat?
colSums( bkgrd.wide != 0 )

# Join with spatial points so that we can plot it spatially.
# Make sure each the data frames have a shared variable.
bkgrd.wide <- left_join( bkgrd.wide, bkgrd.pnts_df, 
                       by = "id")
head( bkgrd.wide )

## If we want to alter the land cover categories: 
## The more categories you use, the more data you require. 
## Think whether you can combine some prior to your analysis. 
## Potential combined categories
bkgrdcover_df <- bkgrd.wide %>% rowwise() %>% #add new columns for combined landcover categories:
  dplyr::mutate( Other = sum( `Open Water`,`Barren Land`,
                              `Evergreen Forest`, `Mixed Forest`, na.rm = TRUE ) )

## View
head( bkgrdcover_df )
colSums( bkgrdcover_df != 0)

# Combine all data components #################################
# Join species and land cover dataframes.
alldata <- left_join( spp_df, cover_df) %>%
  arrange( id ) # Make sure is sorted by site id

# Add weather data.
alldata$MinT <- minTvals
alldata$Rain <- rainvals

# View
head( alldata )

##### Save as .csv file so that it can be used by another script.
write.csv(alldata, file = paste( datadir, "alldata.csv", sep="" ), 
           row.names = FALSE )

# Repeat the process for your background points.
bkgrddata <- left_join( bkgrd.pnts_df , bkgrdcover_df)

# Add weather data.
bkgrddata$MinT <- minTvals.bkgrd
bkgrddata$Rain <- rainvals.bkgrd

# View
head( bkgrddata )

# Save as .csv file so that it can be used by another script:
write.csv( x = bkgrddata, file = paste( datadir, "bkgrddata.csv", sep="" ), 
           row.names = FALSE )

# Checking predictors #################################








*** Maybe save for Later ***
# We start by evaluating the correlation amongst our predictors and also against
# our site locations.
library( psych ) # we only load this package now because we are just using it briefly
alldata %>% ungroup() %>% #ensure data is not grouped
  dplyr::select( -id ) %>% #remove columns that we don't want
  pairs.panels() #create correlation plot
detach( "package:psych", unload=TRUE ) # we remove the package from the workspace


save.image("Workspaces/Save5.RData")
load("Workspaces/Save5.RData")


  








