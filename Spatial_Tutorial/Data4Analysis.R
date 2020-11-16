################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 

# Here we combine all of our cleaned data sets we created in our Prep.R scripts. 
# These include the response and predictor variables we are interested in using 
# for our species distribution model. 
# Here is also the place to perform preliminary checks. Checking for correlation
# among predictors, distributions of the data, possible outliers, etc. 

#################################################################################
# Initial preparation (do this every time you start a new script) ---------------------

# Clear your work space and release your computer's memory.
rm( list = ls() )
gc()

# Install relevant packages.
install.packages( "psych" ) 
install.packages( "ggpubr" )

# Load relevant packages.
library( tidyverse ) 
# Set option to see all columns and more than 10 rows.
options( dplyr.width = Inf, dplyr.print_min = 100 )
library( psych ) #plot correlation among predictors
library( ggpubr )

# Create an object containing your working directory's Path. 
workdir <- getwd()

# Create an object containing your "Data" directory's Path. 
datadir <- paste(workdir, "/Data/", sep = "")


# Importing data #################################

# Import response data:
# Import our cleaned species data.
spp_df <- read.csv( file = paste( datadir, "spp_df.csv", sep="" ) )
# These data contain site-specific coordinates and occupancy counts.

# Import our cleaned habitat data.
hab_df <- read.csv( file = paste( datadir, "hab_df.csv", sep="" ) )
# These data contain the relative coverage of the different land cover types
# for each study site.

# Import predictor data:
# Import our cleaned climate data.
clim_df <- read.csv( file = paste( datadir, "clim_df.csv", sep="" ) )
# These data contain site-specific coordinates in addition to the minimum
# temperature and precipitation normals gathered from the PRISM database and
# averaged across the bird's breeding season June-July.


# Combine all of our data into a single data frame ---------------------------

# Note how each data set contains overlapping information with at least one of the
# other data sets.
# "spp_df" and "hab_df" both have a column representing each site's "id".
# "spp_df" and clim_df both have information on each site's location coordinates.
# These shared columns will allow us to combine all data sets into a single
# data object.

# Make sure that the variable to be joined is formatted correctly.
str( spp_df )
spp_df$id <- as.character( spp_df$id )

str(hab_df)
hab_df$id <- as.character( hab_df$id )

# Join the species and habitat components by "id" into a data frame.
alldata <- left_join( spp_df, hab_df, by = "id" ) %>%
           arrange( id ) # Make sure is sorted by site id

# Double-check that data were combined correctly.
head( alldata ); dim( alldata )

# Now combine with climate data frame.
# Note that the coordinate column names are not conserved between the two data sets.
# Change the coordinate column names in "clim_df" so that they are consistent with 
# those in "alldata".
colnames( clim_df )[ which( colnames( clim_df ) == "coords.x1" ) ] <- "x"
colnames( clim_df )[ which( colnames( clim_df ) == "coords.x2" ) ] <- "y"

# Double-check that the column names have been correctly modified.
colnames( clim_df )

# Join the data sets by the two coordinate columns.
alldata <- left_join( alldata, clim_df, by = c( "x", "y") ) 
  
# Check the combined data frame.
head( alldata ); dim( alldata )
# Note how additional rows were created when "clim_df" was added.  Why?


# Preliminary checks prior to analysis ---------------------------

# One common check is evaluating the correlation among our predictors and also against
# our site locations.
psych::pairs.panels(alldata[, c(2, 3, 26, 27)])
detach( "package:psych", unload=TRUE ) # We remove the package from the workspace

## OR ## 

# Use ggplot with ggpubr to create correlation scatter plots.

# x ~ MinT
ggscatter( alldata, x = "x", y = "MinT", add = "reg.line", conf.int = 0.95, cor.method = "spearman" ) +
  stat_cor( method = "spearman" ) + geom_smooth() + theme_bw()

# x ~ Rain
ggscatter( alldata, x = "x", y = "Rain", add = "reg.line", conf.int = 0.95, cor.method = "spearman" ) +
  stat_cor( method = "spearman" ) + geom_smooth() + theme_bw()

# y ~ MinT
ggscatter( alldata, x = "y", y = "MinT", add = "reg.line", conf.int = 0.95, cor.method = "spearman" ) +
  stat_cor( method = "spearman" ) + geom_smooth() + theme_bw()

# y ~ Rain
ggscatter( alldata, x = "y", y = "Rain", add = "reg.line", conf.int = 0.95, cor.method = "spearman" ) +
  stat_cor( method = "spearman" ) + geom_smooth() + theme_bw()

# Are there any predictors we can/cannot potentially use together in the same model?
# Which and why?
# What other preliminary data checks would you perform?


# Save relevant data and workspaces ---------------------------

##### Save as .csv file so that it can be used by another script.
write.csv( alldata, file = paste( datadir, "alldata.csv", sep="" ), 
           row.names = FALSE )

save.image( "Workspaces/Data4Analysis.RData" )

# Go to SDM_Analysis.R next.

####################      END OF SCRIPT     ######################################