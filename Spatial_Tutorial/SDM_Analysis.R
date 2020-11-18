################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 

# Here, we analyze our data using the sdm package. 
# For more details on the utility of this package see: 
# Naimi, B. & Araújo, M.B. (2016) sdm: a reproducible and extensible R 
# platform for species distribution modeling. Ecography 39:368-375. 

# Our data are presences/absences. 
# We therefore choose models that can take advantage of absences rather than those 
# that rely on background points. 

################################################################################

# Initial preparation (do this every time you start a new script) ---------------------

# Clear your work space and release your computer's memory.
rm( list = ls() ) 
gc()

# Install relevant packages. 
install.packages( "sdm" ) 
# sdm relies on other packages for analysis. Install those associated packages:
sdm::installAll( )
install.packages( "Hmisc" )

# Load relevant packages.
library( tidyverse ) 
# Set option to see all columns and more than 10 rows
options( dplyr.width = Inf, dplyr.print_min = 100 )
library( sdm ) # Species distribution analysis package
library( parallel )
library( Hmisc )

# Loading data and defining required objects -------------------------------  

# Create an object containing your working directory's Path. 
workdir <- getwd()

# Create an object containing your "Data" directory's Path.
datadir <- paste( workdir, "/Data/", sep = "" )

# Import the combined data set produced from Part 4 (alldata.csv).
alldata <- read.csv( file = paste( datadir, "alldata.csv", sep="" ) )

# View imported data.
head( alldata )
glimpse( alldata )

# Set appropriate variable classes.
str( alldata )
alldata$id <- as.factor( alldata$id )

# Remove any duplicated rows using dplyr::distinct().
which( duplicated( alldata$id ) )
alldata <- alldata %>% distinct()
# This function only keeps the first of the duplicated rows.

# Double-check duplicated rows removed
which( duplicated( alldata$id ) )


# Setting general vectors------------------------------- 

# Total number of sites sampled in presence/absence data:
M <- as.numeric( length( alldata$id ) )

# We want to split our data into training and testing sets. 
# Define number of data points to use for testing.
TP <- 1000

# Randomly select which rows to use for testing for our presence/absence data.
t.parows <- sample( x = 1:M, size = TP, replace = FALSE )


# Preparing required response and covariate data for analyses  -------------------

# Predictor data are commonly standardized prior to analysis so that effect sizes 
# are directly comparable. 
# We want to also keep the original values to aid our interpretation of results. 

# Create a data frame to contain standardized covariates.
pa.data <- alldata %>% dplyr::select( -eame ) # Remove data for Eastern Meadowlark

# View the new data frame.
head( pa.data )

# Define predictor names.
covnames <- colnames( pa.data )[ which( !names( pa.data ) %in% c("id", "x", "y", "heth", "SurveyDate", "Year", "julian", "hour" ) ) ]

# Check that you selected the appropriate columns.
head( pa.data[ , covnames ] )

# Standardize each column.
pa.data[ , covnames ] <- apply( pa.data[ , covnames ], MARGIN = 2, scale )

# Double-check the values were standardized appropriately.
head( pa.data[ , covnames ] )

# Note that scale standardizes continuous predictors. 
# How were the values standardized?
# How do we standardize categorical variables?
# Or binomial values?

# Plot predictor distributions:

# There are many different ways to plot data.
# For preliminary checks, it is often easiest to use the basic plotting tools
# provided in R.
# We will be plotting the distributions for all predictor variables (stored in "covnames").

# Check how many plots will be produced:
length( covnames )

# To view all plots simultaneously, we need to create grid with dimensions that can 
# accommodate 18 plots.

# Set the grid dimensions in which the plots will be displayed.
par( mfrow = c(3, 6) )
# Here, we define the output will be 3 rows by 6 columns.

# Write a "for loop" to construct a plot for each covariate name.
for (i in 1:length( covnames) ){
  
  hist( pa.data[ , covnames[i] ], breaks = 8, main = covnames[i] )
  
}
# Click the "Zoom" button in the "Plots" tab to better view the plots.
# You can expand the Zoom window for better visualization.
# You may get an error: "figure margins too large".
# What does this mean?
# How can you fix it?

# When you are finished plotting, use the graphics.off() function to reset the plot space.
graphics.off()

# Calculate correlation coefficients and p-values among covariates.
cov_cor <- Hmisc::rcorr( as.matrix( pa.data[ , covnames ] ), type = "spearman" )
# Note how the output of the rcorr() function is a "list".
# Why was the "spearman" method used?

# Extract the correlation coefficients.
cor_coef <- data.frame( cov_cor[["r"]] ) 
cor_coef
# What do these values tell you?

# Extract the correlation p-values.
cor_p <- data.frame( cov_cor[["P"]] )
cor_p
# What do these values tell you?
# How can you utilize these two data frames to isolate which variables are 
# significantly correlated?

# Create a training data set.
train.padata <- pa.data[ -t.parows, ]

# View the new data frame.
head( train.padata ); dim( train.padata )

# Create a testing data set.
test.padata <- pa.data[ t.parows, ]

# View the new data frame.
head( test.padata ); dim( test.padata )

# What is the significance of creating separate training and testing data sets?


# Analyzing our data -------------------

# To analyze data using sdm we first need to get data ready for analysis using 
# the sdmData() function. 
# By using the "formula" option, we can specify which predictors we want to include
# (on the right-hand side of the equation) and can incorporate multiple species 
# as responses (on the left-hand side of the equation).
# We can specify site locations with coords(x + y) and the data frame that contains our data. 

# Define our data, response, and predictors:
hethd <- sdmData( formula = heth ~ Open.Water + Developed..Open.Space + Developed..Low.Intensity + Developed..Medium.Intensity + Developed..High.Intensity + Barren.Land + 
                  Deciduous.Forest + Evergreen.Forest + Mixed.Forest + Shrub.Scrub + Herbaceuous + Hay.Pasture + Cultivated.Crops + Woody.Wetlands + Emergent.Herbaceuous.Wetlands + Other + MinT + Rain + coords(x + y) + g(id), 
                  train = train.padata, test = test.padata )

# View data details.
hethd

# Now that we've input the data, we are ready to run the analysis. 
# The sdm package allows the concurrent use of multiple methods, however, we will 
# only construct a general linearized model (glm) in this tutorial.
# Make sure that you select methods that are suitable for your data type. 
m1 <- sdm( heth ~., data = hethd, methods = "glm" )
# Since we already defined our predictors in our data object, we can use "." to 
# tell the function to include them all. 
# Note that by doing this we are including covariates that are highly correlated. 
# The authors claim the sdm package can use a variance inflation factor (VIF) 
# to measure how much a predictor is explained by alternative predictors. 
# If it doesn't provide additional information it is removed. 
# The authors claim this can be done in sdm using a stepwise procedure. 

# What are alternative approaches to deal with collinearity in our predictors? 

# View results
m1
getModelInfo( m1 )
# What do these results tell us? 

# What about our predictors? 
# Which are important in modeling the Hermit Thrush distribution? 
# The sdm package can estimate which variables were important using our training data:
vi1.1 <- getVarImp( m1, id = 1, wtest = "training" )

# Plot the results of the model.
plot( vi1.1, "auc", main = "glm" )
# Which variables are influencing the model's results?

# Model evaluation:
# Can our model discriminate whether a species is present at a site or not?
# We assess this by estimating the plot Receiver Operating Characteristic (ROC) Curve (AUC):
roc( m1 )
# What is AUC a measure of? What do the x and y axes represent? 
# You may want to refresh your memory by re-reading:
# Jiménez-Valverde, A. (2012) Insights into the area under the receiver operating 
# characteristic curve (AUC) as a discrimination measure in species distribution modeling. 
# Global Ecology and Biogeography, 21, 498-507. 

# How do the AUC values compare to other measures of misclassification? 
# The sdm package also allows us to evaluate the rate of misclassification using other techniques. 
# Here we calculate the: 
# true skill statistic (TSS), the Receiver Operating Characteristic Curve (AUC), 
# sensitivity (proportion of presences correctly predicted as such), 
# and specificity (proportion of absences correctly predicted as such). 
getEvaluation( m1, stat = c( "TSS", "AUC",  "Sensitivity", "Specificity" ), opt = "max(se+sp)" )
# Note that model performance was evaluated on our independent testing data set. 
# For threshold-based procedures we can select the criteria for optimizing the threshold. 
# Here we chose the option to maximize the true negative and positive rates. 

# What other types of models could be used in addition to "glm".
# Explore these using the sdm package and determine which could best describe the data.
# Also, practice these steps with the Eastern Meadowlark (eame) occupancy data.

# Save required data and workspaces ------------------------------

# Save our data frames as .csv files so that they can be used by other scripts.
write.csv( x = train.padata, file = paste( datadir, "train_padata.csv", sep="" ), 
           row.names = FALSE )
write.csv( x = test.padata, file = paste( datadir, "test_padata.csv", sep="" ), 
           row.names = FALSE )

# We end by saving our workspace so that we can continue working with our results. 
save.image( paste( "Workspaces/SDM_Analysis1.RData", sep = "" ) )


################### END OF SCRIPT ##########################################