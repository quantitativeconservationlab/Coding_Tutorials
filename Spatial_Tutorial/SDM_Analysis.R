################################################################################
# This tutorial was created by Jen Cruz and modified in collaboration with 
# Jonas Frankel-Bricker. 

# We analyze our data using the sdm package. For details on what this package can do read:
# Naimi, B. & Araújo, M.B. (2016) sdm: a reproducible and extensible R platform for species #
# distribution modelling. Ecography, 39, 368-375. #

# Our data arev presences/absences. We therefore choose models that can take advantage
# of absences rather than those that rely on background points. 

################################################################################
# Initial preparation (do this everytime you start a new script) ######################

# Clear your work space and release your computer's memory.
rm(list = ls() ) 
#set working dir() 
gc() #releases memory

##### install relevant packages ####
install.packages( "sdm" ) 

####### load relevant packages ###
library( tidyverse ) 
# set option to see all columns and more than 10 rows
options( dplyr.width = Inf, dplyr.print_min = 100 )
library( sdm ) #Species distribution analysis package.
# sdm relies on other packages for analysis. Install those associated packages:
installAll( )

########## end of package loading ###########

######## loading data and defining required objects -------------------------------  

# set working directory
workdir <- paste( getwd(), "/Spatial_Tutorial/", sep = "" )
#set data directory
datadir <- paste(workdir, "/Data/", sep = "")

# Import .csv file containing combined species and predictor data:
alldata <- read.csv( file = paste( datadir, "/data/alldata.csv", sep="" ) )

# View imported data
head( alldata )
glimpse( alldata )

### Setting general vectors: ####
# Total number of sites sampled in presence/absence data:
M <- max( alldata$id )
# We want to split our data into our training and testing sets: # 
# Define number of data points to use for testing:
TP <- 1000
# Select which rows to use for testing for our presence/absence data:
t.parows <- sample( x = 1:M, size = TP, replace = FALSE )

######## Preparing required response and covariate data for analyses  -------------------

# Predictor data are commonly standardized prior to analysis so that effect sizes are directly #
# comparable. We want to also keep the original values to aid interpretation of results. #

# Create a dataframe to contain standardize covariates:
pa.data <- alldata %>% dplyr::select( -eame ) #remove data for Eastern Meadowlark
# View
head( pa.data )
# Define predictor columns that require standardizing:
covcols <- which( !names( pa.data ) %in% c("id", "x", "y", "heth" ) )
# Define predictor names
covnames <- colnames( pa.data )[ covcols ]
# Check that you selected the right columns
head( pa.data[ , covcols ] )
# Standardize each column
pa.data[ , covcols ] <- apply( pa.data[ , covcols ], MARGIN = 2, scale )
# Note that scale standardizes continuous predictors. How do we standardize categorical ones?
# or binomial ones?

# Plot predictor distributions:
par( mfrow = c( 4, 3 ) )
for (n in covcols ){
  hist( pa.data[ ,n ], breaks = 8, main = colnames( pa.data )[n] )
}
# Check correlations amongst covariates
cor( pa.data[ , covcols ] )
# Create training dataset
train.padata <- pa.data[ -t.parows, ]
# View
head( train.padata ); dim( train.padata )
# Create testing dataset:
test.padata <- pa.data[ t.parows, ]
# View
head( test.padata ); dim( test.padata )

###################################################################################################
########                     Analyzing our data                   #################################
###################################################################################################
# To analyze data using sdm we first need to get data ready for analysis using sdmData(). # 
# By using the formula option we can specify which predictors we #
# want to include, and can incorporate multiple species as responses (on the left-hand side of the equation) #
# We can specify site locations, with coords(x + y), and the dataframe that contains our data. #
# We could actually provide rasters as our predictors, and implement several approaches for #
# estimating a testing dataset (including Cross-Validation). #
# In our example, we do those outside of the package, can you think of reasons why?

# define our data, response and predictors:
hethd <- sdmData( formula = heth ~ Deciduous + Evergreen + Mixed + Forest + Shrub + Crops + 
                    WoodyWetland + Developed + Open + Herb + MinT + Rain + coords(x + y), 
                  train = train.padata, test = test.padata )
# View data details:
hethd

# Now that we've inputed the data we are ready to run the analysis. The sdm package allows the #
# concurrent use of multiple methods. Make sure that you select methods that are suitable for #
# your data type. In this example with presence/absence data we choose three common methods: #
# glm: generalized linear model, rf: random forest, and brt: boosted regression trees. 
m1 <- sdm( heth ~., data = hethd, methods = c( "glm", "rf", "brt" ) )
# Since we already defined our predictors in our data object, we can use . to tell the function #
# to include them all. #
# Note that by doing this we are including covariates that are highly correlated #
# The authors claim the sdm package can use a variance inflation factor (VIF) to measures how much a #
# predictor is explained by alternative predictors. If it doesn't provide additional information it is removed #
# The authors claim this can be done in sdm using a stepwise procedure #

# What are alternative approaches to deal with collinearity in our predictors? #

# View results
m1
getModelInfo( m1 )
# What does these results tell us? #

# What about our predictors? Which are important in modeling the Hermit thrush distribution? #
# The sdm package can estimates which variables were important for each method using our training data:
vi1.1 <- getVarImp( m1, id = 1, wtest = "training" )
vi1.2 <- getVarImp( m1, id = 2, wtest = "training" )
vi1.3 <- getVarImp( m1, id = 3, wtest = "training" )
# Plot results
par( mfrow = c( 3, 1 ) )
plot( vi1.1, "auc", main = "glm" )
plot( vi1.2, "auc", main = "rf" )
plot( vi1.3, "auc", main = "brt" )
# According to these results, which variables are influencing model results?

# Model evaluation:
# Can our model discriminate whether a species is present at a site or not?
# We assess this by estimating, the plot Receiver Operating Characteristic (ROC) Curve (AUC):
roc( m1 )
# What is AUC a measure of? What do the x and y axes represent? 
# You may want to refresh your memory by re-reading:
# Jiménez-Valverde, A. (2012) Insights into the area under the receiver operating #
# characteristic curve (AUC) as a discrimination measure in species distribution modelling. #
# Global Ecology and Biogeography, 21, 498-507. #

# How do the AUC values compare to other measures of misclassification? sdm package also allows us to 
# evaluate the rate of misclassification using other techniques. 
# Here we calculate: #
# the true skill statistic (TSS), the Receiver Operating Characteristic Curve (AUC), #
# the sensitivity (proportion of presences correctly predicted as such), #
# and specificity (proportion of absences correctly predicted as such) #
getEvaluation( m1, stat = c( "TSS", "AUC",  "Sensitivity", "Specificity" ), opt = "max(se+sp)" )
# Note that model performance was evaluated on our independent, testing data #
# For threshold-based procedures we can select the criteria for optimising the threshold #
# here we chose the option to maximise the true negative and positive rates #
# Based on these results, which model would you choose as better? #

###### end ##########

########### save required data and workspaces ------------------------------

##### save our dataframes as .csv files so that they can be used by other scripts:
write.csv( x = train.padata, file = paste( datadir, "train_padata.csv", sep="" ), 
           row.names = FALSE )
write.csv( x = test.padata, file = paste( datadir, "test_padata.csv", sep="" ), 
           row.names = FALSE )

# We end by saving our workspace so that we can continue working with our results in future prac classes:
save.image( paste( workdir, "SDMresults.RData", sep = "" ) )
#notice that the workspace is saved in the working directory NOT in the datadir
# why?

###################     END OF SCRIPT ##########################################