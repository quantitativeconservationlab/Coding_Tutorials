################################################################################
# This tutorial was created by Jonas Frankel-Bricker and Jen Cruz as Part 2 of the 
# "Basic_R" tutorial.  
# "Data_Transformation.R" will walk you through the basics of creating new variables 
# and converting data from wide to long format.
################################################################################


# "Data Transformation" refers to the additional processing and manipulation of a 
# clean data set.
# You will be starting this part of the tutorial with the cleaned data frame produced 
# from Part 1 (CountMatrix_Clean.csv).
# Importantly, you will write code for data transformation (and other parts of the 
# data workflow) in separate R scripts.
# This ensures that all code will be kept organized and easily modifiable.

# To begin this tutorial, follow the "Initial preparation" steps from Part 1 to clear 
# the workspace, release the computer's memory, and set the appropriate working directory.
# Next, create and save a new script.

# Load your workspace from Part 1.
# This will reload all objects created in your previously saved workspace. 
load("Workspaces/Data_Cleaning_Workspace.RData" )
# Alternatively, you could import the cleaned data using the read.csv() function, however, 
# you may need to reassign variable classes.

# You also need to load packages prior to each new coding session.
library( tidyverse )
library( reshape2 )
library( dplyr )

# Working with data in Wide format ------------------------------------------------

# Currently, "CountMatrix_Clean" is in "Wide" format.  
# Wide format data contain independent columns of variables of the same type of data.
# For example, each animal column (Grouse, Rabbit, Rattlesnake, Falcon) contains 
# animal count data, but are separated into different columns.
# There are pros and cons to working with Wide format data.
# Specifically, Wide format allows for the straightforward creation of additional 
# variables that summarrize rows of data.
# Further, initial assessments of data values (such the summary() function you used 
# in Part 1) can perform well on Wide format data.

# First, calculate the the total counts of all animals captured by each camera by 
# summing each animal column for each "Camera_ID" and create a new variable "Total_Counts". 
CountMatrix_Clean$Total_Counts <- CountMatrix_Clean$Grouse + CountMatrix_Clean$Rabbit + CountMatrix_Clean$Rattlesnake + CountMatrix_Clean$Falcon

## OR ##

# Use the rowSums() function to sum the rows of the animal columns.
CountMatrix_Clean$Total_Counts <- rowSums( CountMatrix_Clean[ , c(which( !( colnames( CountMatrix_Clean ) %in% c("Site_Name", "Camera", "Camera_ID") ) ) ) ] )
# Remember, the "!" symbol means opposite.  This line tells R to sum all the values of 
# columns that aren't named "Site_Name", "Camera", or "Camera_ID" for each row.

# Generally speaking, most experimental data are complemented by "metadata". 
# Metadata contain supplemental data that provide additional information for 
# experimental data.
# Example metadata are provided as a .csv file in the "Data" directory named "Metadata".
# These data contain additional information for each Camera_ID, specifically, the 
# lab member that deployed the camera and the date each was deployed.
# Import the metadata file into the R environment and view the metadata.
Metadata <- read.csv("Data/Metadata.csv")
Metadata

# It is often beneficial to merge metadata with experimental data to coalesce all 
# information into a single data object.
# In order to merge two (or more) data sets, at least one variable must be shared.
# For our example, "Camera_ID" is conserved across both data objects.

# Combine "CountMatrix_Clean" with "Metadata" by the shared "Camera_ID" variable into 
# a new data object "CountMatrix_Combined" using the left_join() function.
CountMatrix_Combined <- dplyr::left_join(CountMatrix_Clean, Metadata, by = "Camera_ID")
# Note how the information associated with each "Camera_ID" in "Metadata" have been 
# added to the right side of "CountMatrix_Clean".

# Save the new data frame as a .csv file.
write.csv(CountMatrix_Combined, "Data/CountMatrix_Combined.csv", row.names = FALSE)

# Transforming data from Wide to Long format ------------------------------------------------

# Although experimental data and metadata are often provided in Wide format, many 
# packages and analyses require "Tidy" data.
# In Tidy data, each comparable variable values form a single column with a single 
# value in each row.
# Currently, our data is NOT tidy.
# Animal count data is spread across 4 distinct animal variables, but should be condensed 
# into 1 variable.
# This will transform the data from Wide to "Long" format, resulting in each row containing 
# only one count value.

# There are several different ways to transform data.

# Use the melt() function to move all count data into a single column.
# The variables that will not be condensed are designated with the id.vars argument, 
# whereas the variables not listed will be condensed into a single column.
# The variable.name argument defines the new column name for the variables being 
# condensed, while the value.name argument defines the new column name for the values 
# from the condensed columns.
CountMatrix_Combined_Melt <- reshape2::melt( CountMatrix_Combined, id.vars = c( "Site_Name", "Camera", "Camera_ID", "Total_Counts", "Lab_Member", "Date", "Total_Counts"), variable.name = "Animal", value.name = "Animal_Counts" )

# View the newly created data object.
CountMatrix_Combined_Melt
# How is the data structure different in Long vs Wide format?

# Importantly, new variables have been created whereas others have been removed 
# during the transformation process.
# Double-check that all variables are assigned to the appropriate class.
str( CountMatrix_Combined_Melt )
CountMatrix_Combined_Melt$Animal <- as.character( CountMatrix_Combined_Melt$Animal )

# It is imperative that you fully understand the importance of the transformation 
# you just performed.
# Each row in your new data frame contains a single Animal_Count measurement.
# This means that each "Camera_ID" has 4 unique rows with a count value for each of 
# the 4 animals.
# Also note that the values of each variable defined in the id.vars argument are now 
# repeated 4 times.
# This ensures that all information contained in the Wide format data is still provided 
# for each row of the Long format data (which now has many more rows).

# Working with data in Long format ------------------------------------------------

# Now that the data is Tidy, we can produce additional variables that utilize the 
# new data structure.

# For example, say we want to add the scientific name for each animal as a new variable.
# (Sage-Grouse (Centrocerus urophasianus), Rabbit (Brachylagus idahoensis), 
# Rattlesnake (Crotalus oreganus), Falcon (Falco peregrinus))
# You can now use indexing to assign the appropriate names.

# First create a new empty variable
CountMatrix_Combined_Melt$Scientific_Name <- ""

# Use indexing to define which rows should be assigned a given scientific name in 
# the "Scientific_Name" variable.
CountMatrix_Combined_Melt[which(CountMatrix_Combined_Melt$Animal == "Grouse"), "Scientific_Name"] <- "Centrocerus_urophasianus"
CountMatrix_Combined_Melt[which(CountMatrix_Combined_Melt$Animal == "Rabbit"), "Scientific_Name"] <- "Brachylagus_idahoensis"
CountMatrix_Combined_Melt[which(CountMatrix_Combined_Melt$Animal == "Rattlesnake"), "Scientific_Name"] <- "Crotalus_oreganus"
CountMatrix_Combined_Melt[which(CountMatrix_Combined_Melt$Animal == "Falcon"), "Scientific_Name"] <- "Falco_peregrinus"
# Note how an underscore "_" was used instead of a space for the new scientific names.  
# You should avoid using spaces in R.  

# Create a new variable for the relative occupancy of each animal observed out of 
# the total counts from each "Camera_ID".
CountMatrix_Combined_Melt$Relative_Occupancy <- CountMatrix_Combined_Melt$Animal_Counts / CountMatrix_Combined_Melt$Total_Counts

# Save your data frame as a .csv file.
write.csv(CountMatrix_Combined_Melt, "Data/CountMatrix_Combined_Melt.csv", row.names = FALSE)

# Save your workspace.
save.image("Workspaces/Data_Transformation_Workspace.RData")



### Next Tutorial: "Data Visualization"

