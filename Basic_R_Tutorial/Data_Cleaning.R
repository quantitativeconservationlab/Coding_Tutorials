################################################################################
# This tutorial was created by Jonas Frankel-Bricker as Part 1 of the "Basic_R" tutorial.  
# "Data_Cleaning.R" will walk you through the basics of importing experimental data
# in .csv format and performing basic processing and cleaning of data.
################################################################################

# Any lines beginning with a hashtag "#" indicates "annotation". 
# Lines starting with "#" are not run as code and serve as text within the script.  
# It is imperative that all code you write is thoroughly annotated so that future 
# researchers (and you) can understand and reproduce your code. 

# Preparing to code in R ------------------------------------------------

# The "workspace" is the current "environment" you are working in, in R.
# In your folder it will have a .RData extension.
# Your workspace contains the output of the code you have run within the current R session.
# Clean your workspace to reset your R environment.
rm(list = ls())
# This removes excisting objects you may have created in previous sessions. Those are
# often saved automatically even after you close R. 

# You also need to set your "working directory".
# This is the "Path" of the physical location in your computer where all code, output, 
# and other components of your R Project will be stored.
# This also serves as a point of reference when assigning Paths for other components. 
# For this tutorial, your working directory should be set to your R Project's directory.  
# As you write new code and create new components of your project, it is important that
# you save your work in the appropriate Paths so that you can easily find it later.  
# Check the Path of the directory that you are currently working in using the getwd() function. 
getwd()

# If the output of getwd() is the correct Path (path to your R Project's directory), 
# continue with the rest of the tutorial. 
# If the output of getwd() is incorrect (or if you would like to save your output in 
# a different directory), set the correct Path using the setwd() function.  
# When specifying Paths in R, always wrap the text in quotation marks "".   
# ONLY use setwd() if you wish to change the Path output from getwd().
setwd("CorrectPath")
#can you see how you need to put your own path to replace "CorrectPath in the line above?

# You are now ready to write new code in your R Script. 
# Functions are commands that tell R to perform tasks.  
# All functions follow the syntax: FunctionName(argument)
# The "argument" is code written inside the function's parentheses that specifies 
# various parameters of the function.

# Always begin a script by installing and/or loading the "packages" you will need to run 
# your code.  
# Packages are programs that provide additional "functions" and capabilities to "base" R 
# (the functions/capabilities that already come with R).
# Install new packages that are located in the "CRAN" repository with the 
# install.packages("PackageName") function (note the package names are in quotation marks). 
install.packages("tidyverse")
install.packages("reshape2")
# You only need to install packages once, however, you must load the packages with the 
# library() function prior to starting every new coding session. 
library(tidyverse)
library(reshape2)
# If you have previously installed the packages, 
# load the packages using the library() function.  

# Importing data and preliminary assessments ------------------------------------------------

# A functional line of R code (does not return an error) can be run either in the Script 
# pane (what you are reading this in) or in the "Console" pane at the bottom of the window.   
# Both methods will return an output of the code in the Console pane at the bottom of the 
# window, however, the output will not be stored in the R environment.
# In order to save the output of the code in the R environment, you must use the "assign" 
# symbol (<-) ("strict inequality" key and the "minus" key)

# An R "object" is a named component that stores information (there are many different types
# of objects). 
# Object creation follows the syntax: NameOfObject <- code telling R to create an object
# You can name the objects (avoid special characters and spaces), however, you should keep 
# naming concise and informative.
# Import the experimental data "CountMatrix.csv" into the R environment as a data object.
# Since the data is provided in comma-separated values (.csv) format, use the read.csv() 
# function and specify the path to the data.  
# Note that the Path written is an extension of your working directory 
# (you do not need the full path, unless your data are elsewhere).
CountMatrix <- read.csv( "Data/CountMatrix.csv" )
# Dit it work? How can you tell? 

# The data are now loaded as an object of type "dataframe" and named "CountMatrix".  
# The object can be accessed in the "Data" pane in the top right of the window.  
# Clicking on it will open a new tab showing the contents of the dataframe.  
# These data represent occupancy counts of different animals 
#("Grouse", "Rabbit", "Rattlesnake", "Falcon"), 
#at four geographic locations ("Alpha", "Beta", "Gamma", "Epsilon") 
# captured with 3-4 cameras at each location. 

# After a data object is created, you should perform an initial assessment of the data. 
# The following functions provide basic information of a data object when the object is 
# set as the "argument" (text inside the function's parentheses "()" ).
# The output is informative, but should not be saved as an object.  
# You can either run these functions in the "Script" or "Console" pane.

# View the full data object using the View() function. 
# This is equivalent to clicking on the object in the "Data" pane.
View(CountMatrix)

# Visualize the top rows of a data object using the head() function.
# This is useful to quickly view a portion of data when the object is very large.
head(CountMatrix)

# Show the dimensions (number of rows by columns) of the data object using the dim() function.
dim(CountMatrix)

# Display the names of the columns of the data object using the colnames() function.
colnames(CountMatrix)

# Display the dimensions of the data object and the "class" of the variables (columns) 
#using the str() function.
str(CountMatrix)

# Variables are denoted with a dollar sign "$".  
# It is important that you properly format your data object so that all variables are 
# assigned to the appropriate class.
# There are multiple different kinds of variable classes.

# For our data:

# "Site_Name" contains names of geographic sites.  Names should be assigned as a "character"
# class variable.
# "Site_Name" is correctly assigned as a "character" (chr). 
# You can use the as.character() function to convert variables to character class.

# "Camera" contains numbers, however, the numbers do not have numerical significance 
# (they only denote which camera number is in a geographic location).
# "Camera" can be converted to a "factor" class variable using the as.factor() function.
# Factors have no numeric significance and are grouped into "levels".
CountMatrix$Camera <- as.factor(CountMatrix$Camera)

# The values associated with each animal column ("Grouse", "Rabbit", "Rattlesnake", "Falcon") 
# are occupancy counts and have numerical significance. 
# These need to be converted to "numeric" class variables using the as.numeric() function. 
CountMatrix$Grouse <- as.numeric(CountMatrix$Grouse)
CountMatrix$Rabbit <- as.numeric(CountMatrix$Rabbit)
CountMatrix$Rattlesnake <- as.numeric(CountMatrix$Rattlesnake)
CountMatrix$Falcon <- as.numeric(CountMatrix$Falcon)

# Double-check that variables are now assigned to the correct class.
str(CountMatrix)
# this may seem repetative but is actual a crucial step. You should be checking that each 
# line of code you write is resulting in the intended outcome. Don't just assume that you 
# did it correctly. CHECK EVERY LINE of code.

## Optional: 
## There are many different ways to accomplish tasks in R.  
## Converting variable classes in this example was straightforward due to the small number 
# of variables in the dataframe.
## The following is an example of an alternate method to convert all animal columns to numeric
# If you were working on a camera trap study - this could be the first season of data 
# You can imagine that next season you may get additional animals not detected on this one
# Thus, we need a way to automatically select all columns that are animal counts eventhough 
# we don't know what those may be next season. 

## Remind yourself what the columns are in your dataframe
colnames(CountMatrix)
# What do we do? One option is by selecting everything that is not "Site_Name" or "Camera"
# Those columns will remind consistent throughout your study meaning that your code won't 
# break even if you update your data later! 

#How do we select everything that is not those two columns?
# ! is the equivalent of opposite
# %in% is a function that selects everything in your first argument that matches your second
# so let's try to select the column names that are NOT animal counts
colnames( CountMatrix ) %in% c("Site_Name", "Camera")
# this gives you a logical vector that assigns as TRUE those that match your second argument
# and FALSE as those that dont. Remember your second argument is the Site_Name and Camera columns
# now add the ! function at the start of your argument to reverse this
!( colnames( CountMatrix ) %in% c("Site_Name", "Camera") )
#now that you know it works, assign it as a vector object object.
animal_names <- !( colnames( CountMatrix ) %in% c("Site_Name", "Camera") )

#You can now use this logical vector to easily select the columns that you want to modify in
# your data frame
# Let's check that it works by calling those columns and the first 3 rows using indexing[]
CountMatrix[ 1:3, animal_names ]
# BUT if I could just use numbers to select rows, why didn't I use numbers to select columns.
# Check that it works:
CountMatrix[ 1:3, 1:2 ]
# The problem is that this code relies entirely on your columns never changing their order.
# Otherwise you will accidentally call the wrong column and not know it. 
# If you add a column to your data say because you were adding a unique identifier, or 
# decided there was other attributes you needed (eg. GPS locations ), your column orders will change
# We therefore advice against using indexing to modify objects (it is ok to use to view data)

# Use your logical vector to select your desired columns. Note the row selection (left side of ,)
# is left blank meaning that you select all the rows
# Use lapply function  in tandem with the as.numeric() function to convert all desired columns
# at the same time
CountMatrix[ , animal_names ] <- lapply( CountMatrix[ ,animal_names], as.factor )

## Double-check that variables are now assigned to the correct class. 
str(CountMatrix)


# Cleaning the data -----------------------------------------------------

# Once the variables in your dataframe are properly formatted, summarize the data.
summary(CountMatrix)

# These data have several problems, specifically, the "Mean" count values are unrealistically high.  
# These values are likely impacted by the extreme "Max" outliers, possibly the result of a 
# malfunctioning camera.     
# Viewing our data, the third camera in "Beta" appears to be the malfunctioning camera 
# producing these values.  
# In addition, there are "NA's" in our data (no value present in a cell).
# The third camera in "Epsilon" appears to have been turned off during data collection
# Currently, none of the variables in your dataframe enable you to directly isolate the rows
# corresponding with these faulty cameras.

# It is often beneficial to assign a unique "identifier" for each row
# Create a new variable "Camera_ID" combining the values within "Site_Name" and "Camera" 
# by selecting variables with "$" and utilizing the paste() function.
# Note that this is yet another way to select a desired column
# This code puts an underscore "_" between the values of the variables being combined.
# NEVER use spaces for values within cells.  R does not recognize spaces!
CountMatrix$Camera_ID <- paste(CountMatrix$Site_Name, CountMatrix$Camera, sep = "_")
#Check the first few rows to make sure that it worked
head( CountMatrix, 3 )
#Note that the second argument in head is the number of rows you want displayed (usually 6)

# Look at the entire dataframe to identify the faulty cameras. 
CountMatrix
# Can you see that Cameras "Beta_3" and "Epsilon_3" need to be removed? Why?

## Optional:
## The following is an alternate method using conditions to identify the faulty cameras 
# without manually searching through the dataframe.
## This is really useful when working with large data sets.

## Define a condition that, if violated, would constitute a faulty camera.
## For example, say that you know it would be impossible for there to be more than 1000 Grouse observed by a camera.
## The following code identifies which (if any) rows contain a value > 1000 for the "Grouse" column 
# and returns the corresponding value in the "Camera_ID" column.
CountMatrix[ which( CountMatrix$Grouse > 1000 ), "Camera_ID" ]
# or you can specify the Camera_ID column with $
CountMatrix$Camera_ID[ which( CountMatrix$Grouse > 1000 ) ]
# answer: "Beta_3"

## The is.na() function determines the presence of "NA" in a data set.  
## The following code identifies which (if any) rows contain a "NA" value for the "Grouse" 
# variable and returns the corresponding value in the "Camera_ID" column.
CountMatrix[ is.na(CountMatrix$Grouse), "Camera_ID" ]
# answer: "Epsilon_3"


# You can  remove the values associated with cameras "Beta_3" and "Epsilon_3" to create a new 
# dataframe by implementing "subsetting" or indexing methods.
# The "!=" symbols translate to "does not equal".
# The c() function stands for "concatenate" and combines the arguments defined within the 
# parentheses. 
# IMPORTANT: Many functions from certain packages share names with different functions from 
# other packages.
# For example, subset() is provided in multiple packages.
# If packages are loaded in the same environment, you must define the package you want to 
# source the function using double-colons "::": PackageName::FunctionName()

# Subset the dataframe by removing the faulty cameras using subset() in base R and create a
# new data object.
CountMatrix_Clean <- base::subset( CountMatrix, CountMatrix$Camera_ID != c("Beta_3", "Epsilon_3"))

## OR ##

## Index the dataframe to keep only the correct data and create a new data object.
# == means equals to, while != means not equal to. Thus we are keeping all cameras that are
# NOT "Beta_3" or "Epsilon_3
CountMatrix_Clean <- CountMatrix[ which(CountMatrix$Camera_ID != "Beta_3" & CountMatrix$Camera_ID != "Epsilon_3"), ]
# What if in the next season different cameras malfunction? Can you think of how 
# we can make this code more generalizable? Try it on your own time.

# IMPORTANT:
# When creating new data objects you should keep naming protocols consistent and concise.  

# Summarize the new dataframe to confirm the data has been properly cleaned.
summary(CountMatrix_Clean)

# Saving the data -----------------------------------------------------
# Now that you are happy with your data you can save it so that you can use it
# in other scripts, 

# Save your new dataframe as a .csv file in the Path for the "Data" directory using 
# the write.csv() function.
write.csv( CountMatrix_Clean, "Data/CountMatrix_Clean.csv", row.names = FALSE )

# In other instances you may want to keep all the objects you have created, say
# if you ran some analysis and the results are stored in an object #
# You can save the workspace so that you won't have to run your code every time
# Why would you want to do this?

# Let's save our workspace to see how it works.
# Manually create a new folder in your R Project's directory named "Workspaces".
# Workspaces save all objects created during the R session and can be reloaded into a 
# new environment.
# Save the current workspace as a ".RData" file using the save.image() function and the 
# Path to the "Workspaces" directory.
# Provide an informative name for the workspace.
save.image("Workspaces/Data_Cleaning_Workspace.RData")

#Check that it works: 

# Clean your workspace to reset your R environment.
rm(list = ls())
# Can you see that it is empty?

# You can load the saved workspace using the load() function with the Path to the .RData file..
load("Workspaces/Data_Cleaning_Workspace.RData")



### Next: Data Transformation
### Create new variables (i.e Total_Counts, Species names, Percent of each species out 
###  of total counts (4 new variables))
### Transform data (melt columns into "Species" variable, melt columns into 
### "Relative_Abundance" variable)
### Focus on wide to long format (i.e. "Tidy" data)

######################## END OF SCRIPT ##################################################