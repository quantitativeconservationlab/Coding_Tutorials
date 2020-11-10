################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 
#
# The distribution of hermit thrush during the breeding season in Wisconsin #
# may be driven by climate. For our analysis we explore whether rainfall and temperature #
# during the breeding season of hermit thrush influence its distribution. 
#
# We use PRISM database to obtain national climate data for the lower 48 states
# of the USA across 30 years at a resolution of 800m.
# We need to reduce the national dataset to Wisconsin.
# We use minimum temperature and rainfall during the Hermit Thrush breeding season (June - July).
#
# We work primarily with "raster" class objects.
# Please see the following link for more information on raster data: 
# https://geocompr.robinlovelace.net/spatial-class.html#raster-data
#
#################################################################################
# Initial preparation (do this everytime you start a new script) ######################

# Clear your work space and release your computer's memory.
rm( list = ls() )
gc()

# Install the required packages.# remember this is only done once. 
install.packages( "prism" ) # Extracts climate data from PRISM
install.packages( "rasterVis" )
install.packages( "latticeExtra" ) # for visualizing

# Load relevant packages. This is done every time you open Rstudio #
library( prism ) #package for downloading prism data
library( rgdal ) # Imports projects and transforms spatial data. Requires the "sp" package.
library( raster )
library( rasterVis ) # Visualizes rasters
library( latticeExtra )

# Importing data #################################
# set working directory
workdir <- paste( getwd(), "/Spatial_Tutorial/", sep = "" )

#set data directory
datadir <- paste(workdir, "/Data/", sep = "")

# Import Wisconsin shapefile to subset our data 
WI <- rgdal::readOGR( paste( datadir, "Wi_State_Outline/WI_state_outline.shp", sep="" ) )
# Make a quick plot.
plot( WI )

# import our sites spatial points:
sites <- rgdal::readOGR( paste( datadir, "sites.shp", sep="" ) )

# Downloading climate data #################################

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

# Data are Minimum temperature and precipitation normals for June and July.
# We need to subset these to  Wisconsin.
# We prepare temperature and precipitation separately 
# We then combine data from June and July by calculating mean values, 
# and subsetting the processed data.

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

#check
dim(MinT)
# The object now has only 1 layer.

# Label the resulting column.
names( MinT ) <- c( "minT" )
names( MinT )

# Plot seasonal (Jun-Jul) mean for minimum temperature 30yr normals.
rasterVis::levelplot( MinT )  + 
  latticeExtra::layer( sp.polygons( WI, col = 'white', lwd = 2 ) )
# Plot construction may take several minutes to complete.  
# Why do you think our plot contains data that falls outside of Wisconsin's borders?

# Remove intermediate large rasters produced during the workflow.
rm( "MinTAll", "MinTWI" )

# Now that we have seasonal data for Wisconsin we need to match them to our site locations. 
# Extract values for each site location.
minTvals <- raster::extract( MinT, sites )

# Double-check that each site has an associated value.
head( minTvals ); length( minTvals )

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

# Plot seasonal (Jun-Jul) mean for precipitation normals.
rasterVis::levelplot( Rain )  + 
  latticeExtra::layer( sp.polygons( WI, col = 'white', lwd = 2 ) )

# Remove intermediate large rasters produced during the workflow.
rm( "RainAll", "RainWI" )

# Now that we have seasonal data for Wisconsin we need to match them to our site locations. 
# Extract values for each site location.
rainvals <- raster::extract( Rain, sites )

# Double-check that each site has an associated value.
head( rainvals ); length( rainvals )

# Combine site locations to climate values
clim_df <- as.data.frame( sites@coords ) %>%
  #we can use mutate to add multiple new columns 
  dplyr::mutate( MinT = minTvals, 
                 Rain = rainvals )

# Check
head( clim_df ); dim( clim_df )

################ save relevant data and workspaces ---------------------------

# Save the cropped raster as a GTiff (.tif) file using the writeRaster() function.
writeRaster( MinT, filename = paste( datadir, "/MinT.tif", sep = "" ), 
             format = "GTiff" )

# Save the cropped raster as a GTiff (.tif) file using the writeRaster() function.
writeRaster( Rain, filename = paste( datadir, "Rain.tif", sep = "" ), 
             format = "GTiff" )

##### Save as .csv file so that it can be used by another script.
write.csv( clim_df, file = paste( datadir, "clim_df.csv", sep="" ), 
          row.names = FALSE )

# Go to Habitat.Prep.R next. 
################   END OF SCRIPT      ###########################################