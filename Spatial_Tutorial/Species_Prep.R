################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 

# The Spatial_Tutorial will walk you through an example of how to prepare and combine
# a variety of different data types for analysis with a basic species distribution
# model (SDM).  We begin with data download and preparation.  Data include species, 
# climate, and habitat data. We then combine them all for analysis.
#
# Please review the readme file for details of the data and model you will be using. 
#
# If you are new to spatial data, first review Chapter 2 from the online tutorial
# located at: https://geocompr.robinlovelace.net/spatial-class.html
################################################################################

# Initial preparation (do this every time you start a new script) ######################

# Clear your work space and release your computer's memory.
rm( list = ls() )
gc()

# Install the required packages.
# Remember this is only done once. 
install.packages( "tidyverse" ) # Tidyverse includes "dplyr", "tidyr", and "ggplot2" and others
install.packages( "rgdal" )
install.packages( "sp" )
install.packages( "sf" ) 
install.packages( "maptools" )

# Load relevant packages. This is done every time you open Rstudio. 
library( tidyverse ) # A group of packages for easy coding including ggplot2, tidyr, dplyr, etc.
# Set global dplyr option to see all columns and more than 10 rows.
options( dplyr.width = Inf, dplyr.print_min = 100 )
library( rgdal ) # Imports projects and transforms spatial data. Requires the "sp" package.
library( sp )
library( sf ) # Great new package to easily view and manipulate spatial data.
library(maptools) # Reads and manipulates ESRI shape files.

# Importing and checking shape files and species data #################################

# Check your working directory, which should be where your RStudio project is. 
getwd()
# You can use setwd() to adjust if needed. Or maybe you are in the wrong Rstudio project?

# Create an object containing the working directory's Path. 
# This may differ depending on your directory structure.
# What is yours?
workdir <- getwd()

# Create an object containing your "Data" directory's Path.
# Here we set it as a subdirectory in the RProject folder but remember that you 
# probably want yours to be in your Google Drive so that your data are getting backed up. 
datadir <- paste(workdir, # The paste function combines two character objects.
                 "/Data/", # Path to our subdirectory.
                 sep = "") # Joins the two Paths with no spaces.
# "datadir" is a character object containing the Path to the "Data" subfolder.
# Assigning directories this way helps to automate data handling and eliminate manual 
# transfer of data files. 

# First, let's import a shapefile (.shp) of Wisconsin. 
# Importing a shapefile with the "rgdal" package also imports its projection. 
# You can also import shapefiles without projections using the maptools package. 

# Import Wisconsin shapefile including its projection using the readOGR() function.
WI <- rgdal::readOGR( paste( datadir, "Wi_State_Outline/WI_state_outline.shp", sep="" ) )
# This creates a Spatial Polygons data frame class object.
# For this function to work, you need the .shp file and the other associated files 
# located in the same Path.
# View the file details.
summary( WI )
# What do you think the "min" and "max" values represent in the "Coordinates:" tab?

# Make a quick plot.
plot( WI )

# Now import the species data.
# The "sppdata.csv" file contains simulated presence/absence observations of two bird species
# to resemble sampling from the Wisconsin Bird Atlas. 
# The file also contain survey locations represented as eastings and northings.
# For more details on Wisconsin Bird Atlas (2016-2017) see: 
# http://www.uwgb.edu/birds/wbba/index.htm

# Here we focus on the Hermit Thrush ("heth") data. 
# Data for the Eastern Meadowlark ("eame") are available for you to practice with. 

# Remember we created a Path to the data folder. 
# Here we use it to define the correct Path to the file to import.
spp_df <- read.csv( file = paste( datadir, "sppdata.csv", sep = "" ), # Specifies the data file name
                    header = TRUE, # Keeps column labels
                    strip.white =TRUE ) # Removes white spaces 
# The paste() function was used to combine the Paths of your data directory 
# with the path to the data file.

# Check that the data were imported correctly:
glimpse( spp_df )

# View first and last rows of the data frame.
head( spp_df ); tail( spp_df )
# The semicolon allows you to run two separate functions on the same line and view 
# both outputs in the Console pane.

# Check the structure of the data frame and adjust variable classes as needed. 
str( spp_df )
spp_df$id <- as.character( spp_df$id )
spp_df$Year <- as.factor( spp_df$Year )

# "id" represents the site name where the survey took place.
# The values in "heth" reflect whether the bird was present (1) or absent (0) at each site.
# "x" and "y" are GPS coordinates defined by a specific Coordinate Reference System (CRS).
# When you import spatial data into R you can specify the CRS using its EPSG code. 
# See: http://www.spatialreference.org 
# You should always know what the CRS is for the spatial data you plan to use (or collect).
# For additional information regarding CRS review the resources available at:
# https://geocompr.robinlovelace.net/spatial-class.html#crs-intro 

# How many presences and absences were observed?
table( spp_df$heth )
# What does this tell you about your sample size?

# View the spatial distribution of your observations using the "ggplot2" package.
ggplot( data = spp_df, # Selects the data source you want to plot 
        aes( x, y, color = factor( heth ) ) ) + # Uses species observations to color-code locations
  geom_point() + # Plots locations as points
  theme_bw() # Assigns a black and white preset theme to the plot
# How are hermit thrush distributed in Wisconsin based on the observations?
# What does it tell you about the bird's ecology? 
# What other checks do you need to make for your own data? 
# Is the sampling biased? 

# Site locations were recorded using the NAD_1983_HARN_Wisconsin_TM CRS. 
# We use the epsg code to define the coordinate system for our sites.
siteproj <- sp::CRS(  "+init=epsg:3071" )
# This creates a CRS class object containing the parameters of the CRS.
# Note that we specify which package the function comes from using a double-colon. 
# This is often good practice. 

# We now create spatial points using eastings and northings of the site locations
# from spp_df and the correct CRS projection we defined earlier. 
sites <- sp::SpatialPoints( coords = spp_df[, c( "x", "y" ) ], # Choose coordinate columns
                            proj4string = siteproj ) # Define projection
# This creates a SpatialPoints class object containing the coordinates for each
# point and the CRS parameters.

# View attributes and first rows.
class( sites ); head( sites )

# Now we ensure all our spatial data are in the same projection.
# We convert the projection of our Wisconsin shapefile to match our site projection.
WI <- sp::spTransform( WI, proj4string( sites ) )
# Note: A common mistake when working with spatial data is forgetting to match their 
# projections, which can introduce significant errors in your analysis.
# This is particularly common when you are sourcing data from multiple locations. 

# Quick check if your sites are within your study area polygon. 
plot( WI )
points( sites )
# Are they within your study region? 
# Caution: Mistakes are common when transcribing x, y locations.

################ Save relevant data and workspaces ---------------------------

# Save clean dataframe as .csv file so that it can be used by another script.
write.csv( spp_df, file = paste( datadir, "spp_df.csv", sep= "" ), 
          row.names = FALSE )

# Convert "sites" to an sf object.
sites <- sf::st_as_sf( sites )

# Save site locations as shapefile.
sf::st_write( sites, paste( datadir, "sites.shp", sep = ""), driver = "ESRI Shapefile" )

# Save workspace in a manually created subdirectory.
save.image( paste( workdir, "/Workspaces/Species_Prep1.RData", sep = "" ) )

# Go to Climate_Prep.R next.

####################      END OF SCRIPT     ######################################


