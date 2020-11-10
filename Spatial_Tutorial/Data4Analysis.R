################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 
#
# Here we combine all our cleaned dataset we created in our Prep.R scripts. 
# These include the response and predictor variables we are interested in using 
# for our species distribution model. 
#
# Here is also the place to perform preliminary checks. Checking for correlation
# among predictors, distributions of the data, possible outliers, etc. 
#
#################################################################################

# Initial preparation (do this everytime you start a new script) ---------------------

# Clear your work space and release your computer's memory.
rm( list = ls() )
gc()

##### install relevant packages ####
install.packages( "psych" ) 

####### load relevant packages ###
library( tidyverse ) 
# set option to see all columns and more than 10 rows
options( dplyr.width = Inf, dplyr.print_min = 100 )
library( psych ) #plot correlation among predictors

# Importing data #################################
# set working directory
workdir <- paste( getwd(), "/Spatial_Tutorial/", sep = "" )

#set data directory
datadir <- paste(workdir, "/Data/", sep = "")

###### Import response data:
# Import our cleaned species data
spp_df <- read.csv( file = paste( datadir, "spp_df.csv", sep="" ) )

###### Import predictor data:
# Import our cleaned climate data
clim_df <- read.csv( file = paste( datadir, "clim_df.csv", sep="" ) )

#Import our cleaned habitat data
hab_df <- read.csv( file = paste( datadir, "hab_df.csv", sep="" ) )

#### Combine all our data into a single dataframe ---------------------------
# Join species and land cover dataframe.
alldata <- left_join( spp_df, hab_df, by = "id" ) %>%
          arrange( id ) # Make sure is sorted by site id

#check
head( alldata ); dim( alldata )

# Now add climate dataframe
alldata <- left_join( alldata, clim_df, by = c( "x", "y") ) 
  
#check
head( alldata ); dim( alldata )

# Preliminary checks prior to analysis ---------------------------
# One common check is evaluating the correlation amongst our predictors and also against
# our site locations.
alldata %>% ungroup() %>% #ensure data is not grouped
  dplyr::select( -id ) %>% #remove columns that we don't want
  pairs.panels() #create correlation plot
detach( "package:psych", unload=TRUE ) # we remove the package from the workspace

#are there any predictors we cannot potentially use together in the same model?
# which and why?

# What other preliminary data checks would you perform?


################ save relevant data and workspaces ---------------------------

##### Save as .csv file so that it can be used by another script.
write.csv( alldata, file = paste( datadir, "alldata.csv", sep="" ), 
           row.names = FALSE )

####################      END OF SCRIPT     ######################################