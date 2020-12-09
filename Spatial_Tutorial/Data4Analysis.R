################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 

# Here we combine all of our cleaned data sets we created in our Prep.R scripts. 
# These include the response and predictor variables we are interested in using 
# for our species distribution model. 
# Here is also the place to perform preliminary checks. Checking for correlation
# among predictors, distributions of the data, possible outliers etc. 

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
library( psych ) # Plot correlation among predictors
library( ggpubr )

# Create an object containing your working directory's Path. 
workdir <- getwd()

# Create an object containing your "Data" directory's Path. 
datadir <- paste( workdir, "/Data/", sep = "")


# Importing data #################################

# Import response data:
# Import our cleaned species data.
spp_df <- read.csv( file = paste( datadir, "spp_df.csv", sep="" ) )
# These data contain site-specific coordinates and occupancy counts.

# Check:
head( spp_df ); dim( spp_df )

# Import our cleaned habitat data.
hab_df <- read.csv( file = paste( datadir, "hab_df.csv", sep="" ) )
# These data contain the relative coverage of the different land cover types
# for each study site.
# Check:
head( hab_df ); dim( hab_df )

# Import predictor data:
# Import our cleaned climate data.
clim_df <- read.csv( file = paste( datadir, "clim_df.csv", sep="" ) )
# These data contain site-specific coordinates in addition to the minimum
# temperature and precipitation normals gathered from the PRISM database and
# averaged across the bird's breeding season June-July.

# Check:
head( clim_df ); dim( clim_df )

# Combine all of our data into a single data frame ---------------------------

# Note that all data frames contain the same number of rows and how
# each dataframe contains overlapping information. 
# "spp_df" and "hab_df" both have a column representing each site's "id".
# "clim_df" has a column "FID", which is associated with "id" (it equals id - 1), 
# which sometimes happens when working with different data sets.
# These shared columns will allow us to combine all data sets into a single
# data object.

# Make sure that the variable to be joined is formatted correctly.
str( spp_df )
spp_df$id <- as.factor( spp_df$id )

str(hab_df)
hab_df$id <- as.factor( hab_df$id )

# Join the species and habitat components by "id" into a data frame.
alldata <- left_join( spp_df, hab_df, by = "id" ) %>%
           arrange( id ) # Make sure is sorted by site id

# Double-check that data were combined correctly.
head( alldata ); dim( alldata )
# Note that the number of rows was maintained. This is a really important
# check when joining data frames....sometimes if we do not code it correctly
# we can either inadvertently remove or add rows.

# Now combine with climate data frame.
# First, we need to add an "FID" column to "alldata" so that the data sets can
# be joined by a common variable.
alldata$FID <- clim_df$FID

# Join the data sets by the two coordinate columns.
alldata <- left_join( alldata, clim_df, by = "FID" ) 
  
# Check the combined data frame.
head( alldata ); dim( alldata )


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
# Which weather variable is correlated to latitude (y)? does it make sense?

# What other preliminary data checks would you perform?
# What does the "Removed rows containing non-finite values" error tell you?
# How can you fix this issue?


# Save relevant data and workspaces ---------------------------

##### Save as .csv file so that it can be used by another script.
write.csv( alldata, file = paste( datadir, "alldata.csv", sep="" ), 
           row.names = FALSE )

save.image( "Workspaces/Data4Analysis.RData" )

# Go to SDM_Analysis.R next.

####################      END OF SCRIPT     ######################################