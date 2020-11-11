################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 

# We want to see if habitat type influences the distribution of our species. 
# We use landcover data from the National Geospatial Data Asset (NGDA).
# https://www.mrlc.gov/data/nlcd-2016-land-cover-conus
# We downloaded data from 2016 directly from the website and extracted them into 
# a subdirectory in our Data folder called "NLCD_LandCover_2016".
# We are interested in land cover surrounding our sites only. 
# We import the complete file first and then extract land cover values around our 
# sites (using a buffer). 

################################################################################
# Initial preparation (do this everytime you start a new script) ######################

# Clear your work space and release your computer's memory.
rm( list = ls() )
gc()

# Install the required packages.# remember this is only done once. 
install.packages( "raster" ) # Extracts climate data from PRISM

# Load relevant packages. This is done every time you open Rstudio #
library( tidyverse )
library( rgdal ) # Imports projects and transforms spatial data. Requires the "sp" package.
library( raster ) # manipulating and using raster files
library( rgeos ) # Spatial manipulation functions i.e. buffer and interpolate

# Importing data #################################

# Create an object containing the working directory's Path. 
# This may differ depending on your directory structure.
# What is yours?
workdir <- getwd()

# Create an object containing your "Data" directory's Path.
datadir <- paste( workdir, "/Data/", sep = "" )

# Set path to habitat layer .img file.
habpath <- paste( datadir, "NLCD_LandCover_2016/NLCD_2016_Land_Cover_L48_20190424.img", sep = "" )

# Import .img file as a raster file using the "raster" package.
habrast <- raster::raster( habpath )

# Check the data by making a basic plot.
plot( habrast )

# Import the legend for the 2016 NLCD data.
nlcdlegend <- read.csv( paste( datadir, "NLCD_LandCover_2016/NLCD_Land_Cover_Legend.csv", sep = "") )

# View the legend.
head( nlcdlegend, 15 )

# What are the possible habitat types?
unique( nlcdlegend$Legend )

#import clean species dataframe to extract 
spp_df <- read.csv( paste( datadir, "spp_df.csv", sep = ""), header = TRUE )

# import our sites spatial points:
sites <- rgdal::readOGR( paste( datadir, "sites.shp", sep = "") )
  
# Convert CRS of site points to match habrast.
sites_transf <- spTransform( sites, proj4string( habrast ) )
# Why do we do it this way and not the other way around?
# "sites" is a much smaller file than the NLCD  data so it is much faster to do this.
# Notice that we didn't actually replace our sites but created a new "sites_transf" object.

#### Extract landcover for our sites ------------------------------------------

# Create a function that summarizes the proportion of each cover type 
# for each site.

# Required inputs:
# lcraster = nlcd habitat raster object ("habrast")
# nlcdlegend = nlcd legend ("nlcdlegend")
# sites = spatial points of study sites ("sites_transf)
# siteid = unique transect ids where we extract habitat (spp_df$id)
# buf = buffer radius size in meters over which we extract habitat
# if set to NULL then habitat is extracted at the point (no buffer)

# Output:
# Data frame with proportions of habitats found within buffer area 
# surrounding study sites.
# When are functions useful? Why create them?

summarize_landcover <- function( lcraster, nlcdlegend, sites, siteid, buf = NULL ){
  
  # Convert transect location projection to match NLCD data projection.
  temp.points <- sp::spTransform( sites, proj4string( lcraster ) )
  
  # Extract land cover data at each site within specified buffer. 
  Landcover <- raster::extract( lcraster, temp.points, buffer = buf )
  
  # Summarize land cover as a proportion for each site.
  summ <- lapply( Landcover, function( x ) prop.table( table( x ) ) )
  
  # Extract habitats found at our sites.
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

habdf <- summarize_landcover( lcraster = habrast, nlcdlegend = nlcdlegend, 
          sites = sites_transf, siteid = spp_df$id, buf = 35 )

# View the output of the function.
head( habdf ); dim( habdf )
table( habdf$cover.lab )

# Plot histograms of habitat types found at our sites
ggplot( habdf, aes( x = proportion * 100 ) ) + 
  theme_classic() + 
  xlab( "Habitat (%)" ) +
  geom_histogram( position = "identity", alpha = 0.5, bins = 5 ) + 
  facet_wrap( ~cover.lab, scales = "free_y" )

# Transform data frame from long to wide format to append to sites.
hab.wide <- habdf %>% dplyr::select( -cover.id )%>%
  # Convert to wide format
  tidyr::spread( key = cover.lab, value = proportion, fill = 0 )

# Double-check that data was transformed correctly.
head( hab.wide ); dim( hab.wide )

# How many entries did we have for each habitat?
colSums( hab.wide!= 0 )

# If we want to alter the land cover categories: 
# The more categories you use, the more data you require. 
# Think whether you can combine some prior data to your analysis. 
# Potential combined categories:
hab_df <- hab.wide %>% rowwise() %>% # Add new columns for combined landcover categories:
  dplyr::mutate( Other = sum( `Open Water`,`Barren Land`,
                              `Evergreen Forest`, `Mixed Forest`, na.rm = TRUE ) )
hab_df <- data.frame( hab_df )

# View the new data frame.
head( hab_df )
colSums( hab_df !=0 )

################ save relevant data and workspaces ---------------------------

##### Save as .csv file so that it can be used by another script.
write.csv( hab_df, file = paste( datadir, "hab_df.csv", sep= "" ), 
           row.names = FALSE )

save.image( "Workspaces/Habitat_Prep1.RData" )

# Go to Data4Analysis.R next. 

################### END OF SCRIPT ##########################################
