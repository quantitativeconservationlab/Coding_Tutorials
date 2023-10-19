################################################################################
# This tutorial was created by Jen Cruz to help import daymet data for a #
# specific set of sites. The tutorial is based on:  #
# https://cran.r-project.org/web/packages/daymetr/vignettes/daymetr-vignette.html #
# daymet data from: #
# https://daac-news.ornl.gov/content/daymet-v4-revision-1-released-november-1-2022 #
# daymet datum is WGS_84 #
# spatial resolution is 1 km grid cell. #
##############################################################################
# Initial preparation (do this every time you start a new script) ######################

# Clear your work space and release your computer's memory.
rm( list = ls() )
# Install the required packages.
install.packages( "daymetr" ) # Extracts climate data from daymet

# Load relevant packages. This is done every time you open Rstudio. 
library( daymetr ) #package for downloading prism data
library( sf )
library( tidyverse)
## end of package load ###############
###########################################################################
############# import relevant data ########################################

#define where you want the data dowloaded. Probably our Zdrive
datadir <-  "Z:/Common/QCLData/Climate/daymet_Alaska/"
#define where you have site csv
sitedir <-  "Z:/Common/GroundSquirrels/CleanData/"

#load your sites so you can set them to the correct format #
#required by daymet
#here I load a shapefile and convert it to csv after checking that
# the locations are correct and matching the coordinate system with 
# daymet. BUT you can inport a csv here instead and turn it into 
# a spatial sf object for plotting and manipulation before saving 
# the cleaned csv to your local workspace to then upload again in 
# the daymet download function
sites <-  sf::st_read( paste0(sitedir, "allsites.shp") , 
                       quiet = TRUE )

#load NCA polygon as example
#load NCA shapefile 
NCA <- sf::st_read( "Z:/Common/QCLData/Habitat/NCA/GIS_NCA_IDARNGpgsSampling/BOPNCA_Boundary.shp", 
                    quiet = TRUE)

################################################################
################## prepare data ################################
# we prepare sites for import 

#view site shapefile:
head(sites )
# it is in Easting Northings using NAD83, UTM zone 11N

#first step is to convert geometry to lat long WGS_84 to match daymet
#Here i create an object that has the correct EPGS for the CRS:WGS_84 is EPSG:4326
daymetcrs <- 4326
#transform sites sf object to coordinate system that matches daymet data:
sites_trans <- sf::st_transform( sites, crs = daymetcrs )
#transform coordinates of NCA polygon to match daymet
NCA_trans <- sf::st_transform( NCA, crs = daymetcrs )
#check that it worked
head(sites_trans)
#Plot sites to check that they are near each other
#you could add a polygon of your study area here to check that 
#they are in the right location!
ggplot( sites_trans ) +
  theme_classic() +
  geom_sf() + 
  geom_sf( data = NCA_trans, fill = NA )


#extract coordinates onto separate columns
sites_trans <- sites_trans %>% 
dplyr::mutate(lon = sf::st_coordinates(.)[,1],
              lat = sf::st_coordinates(.)[,2])

#convert to dataframe by dropping geometry
sites_df <- st_drop_geometry( sites_trans ) %>% 
  #reorder and relabel columns as required for daymet
  dplyr::select( site = Site, latitude = lat, longitude = lon )
head(sites_df)


#####################################################################
# Download climate data #################################
#climate variable options include:
#vapour pressure (vp), minimum and maximum temperature (tmin,tmax),#
#snow water equivalent (swe), solar radiation (srad), precipitation (prcp), #
# day length (dayl) #

### the package comes with tile_outlines (which are polygons) #
# you can view them here:
ggplot(tile_outlines)+ 
  geom_sf() +
  theme_void()

#intercept the sites with the tiles to work out which we need 
# to download
out <- st_intersection( sites_trans, tile_outlines )
head( out)
#extract tile ids
site_tiles <- unique( out$TileID)
#download daymet data for relevant tiles
download_daymet_tiles(
  tiles = site_tiles,
  start = 1980,
  end = 1981,
  path = datadir,
  param = "ALL",
  silent = FALSE,
  force = FALSE
)

#####Alternatively if we want to download data for each site######
# #save in working directory as csv file for use in daymet download 
write.csv( x= sites_df, file = paste0( sitedir,"sites_df.csv" ), 
           row.names = FALSE )
#download data at each site
download_daymet_batch(
  #define file name and location for site coordinates
  file_location = paste0( sitedir,"sites_df.csv" ),
  start = 2010,
  end = 2011,
  #if internal is FALSE then data are downloaded to disk
  internal = FALSE,
  #define where you want data downloaded
  path = datadir
)
#### end of site-level download ###
################## end of script ##########################################