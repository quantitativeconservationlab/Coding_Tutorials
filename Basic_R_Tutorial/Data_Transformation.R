################################################################################
# This tutorial was created by Jonas Frankel-Bricker and Jen Cruz as Part 2 of the 
# "Basic_R" tutorial series.  
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
# variables that summarize rows of data.
# Further, initial assessments of data values (such the summary() function you used 
# in Part 1) can perform well on Wide format data.

# First, calculate the the total counts of all animals captured by each camera by 
# summing each animal column for each "Camera_ID" and create a new variable "Total_Counts". 

# We could do it by creating a new column and assigning it the sum of each column of interest:
CountMatrix_Clean$Total_Counts <- CountMatrix_Clean$Grouse + CountMatrix_Clean$Rabbit + CountMatrix_Clean$Rattlesnake + CountMatrix_Clean$Falcon

# But if you have multiple animal species you can see how this quickly becomes unmanageable 
# what happens if you get different species on your second season of field work? 
# Your code will no longer work!

### OR ###

## You could use the rowSums() function to sum the rows of the animal columns.
# Remember from the cleaning script that you could exclude your id columns 
# using a combination of ! and %in%.

# You could call the rowSums() function excluding those columns:
rowSums( CountMatrix_Clean[ , !( colnames( CountMatrix_Clean ) %in% c("Site_Name", "Camera", "Camera_ID") ) ] )
# Remember, the "!" symbol means opposite.  This line tells R to sum all the values of 
# columns that aren't named "Site_Name", "Camera", or "Camera_ID" for each row.

### OR ###

# You could use %>% 'piping'. 
# See here: https://www.datacamp.com/community/tutorials/pipe-r-tutorial for more details. 
# Piping is a really good way to run multiple steps in one go. 
# You can also combine it with ggplot, which allows you to modify your data for plotting 
# without having to save intermediate steps.

# Here we want to use the function select() to choose everything outside the ID 
# columns and then sum the remaining columns. Notice that each action is separated by the %>%:
CountMatrix_Clean %>% dplyr::select( -Site_Name, -Camera, -Camera_ID ) %>% rowSums()

# After testing that it works you can then create the new variable called Total_Counts.
# Let's break this down into separate lines so that you can see how each works:
CountMatrix_Clean[ , "Total_Counts"] <- CountMatrix_Clean %>% # Here we are saving our changes to the object.
  dplyr::select( -Site_Name, -Camera, -Camera_ID ) %>% # We now select the columns we want exclude.
  rowSums()  # We now sum the rows.

# Did it work?
head( CountMatrix_Clean )

# Generally speaking, most experimental data are complemented by "metadata". 
# Metadata contain supplemental data that provide additional information for 
# experimental data.
# Example metadata are provided as a .csv file in the "Data" directory named "Metadata".
# These data contain additional information for each Camera_ID, specifically, the 
# lab member that deployed the camera and the date each was deployed.

# Import the metadata file into the R environment and view the metadata.
Metadata <- read.csv( "Data/Metadata.csv", fileEncoding = "UTF-8-BOM" )

# View
head( Metadata )

# It is often beneficial to merge metadata with experimental data to coalesce all 
# information into a single data object.
# In order to merge two (or more) data sets, at least one variable must be shared.
# For our example, "Camera_ID" is conserved across both data objects.

# Combine "CountMatrix_Clean" with "Metadata" by the shared "Camera_ID" variable into 
# a new data object "CountMatrix_Combined" using the left_join() function.
# Sometimes left_join() can create extra or less rows, make sure you understand how it works
# and check that you are getting the desired result 
# Check out the data-wrangling-cheatsheet for more info:
# https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf 
CountMatrix_Combined <- dplyr::left_join(CountMatrix_Clean, Metadata, by = "Camera_ID")

# Did it work?
head( CountMatrix_Combined ) 
# Note how the information associated with each "Camera_ID" in "Metadata" have been 
# added to the right side of "CountMatrix_Clean".

#Importantly, did it create the same number of rows as the original dataframe:
dim( CountMatrix_Clean); dim( CountMatrix_Combined )


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

# Here we use the melt() function to combine species count into a single column.
# melt() is part of the reshape2 package. 
# Alternatively, check out the cheatsheet for plyr package alternatives.
# In melt(), the variables that are not to be condensed are designated with the id.vars argument, 
# with the remaining variables, not listed, condensed into a single column.
# The variable.name argument defines the new column name, 
# while the value.name argument defines the new column name for the values 
# from the condensed columns.
CountMatrix_Combined_Melt <- reshape2::melt( CountMatrix_Combined, 
            id.vars = c( "Site_Name", "Camera", "Camera_ID", 
                    "Lab_Member", "Date", "Total_Counts" ), variable.name = "Animal", 
            value.name = "Animal_Counts" )
# Note how we specify the package. Also note that we often break up the code into multiple lines.
# That is only so we can read easier. 

# View the newly created data object.
head( CountMatrix_Combined_Melt )
# How is the data structure different in Long vs Wide format?
# How are total counts different from animal counts?

# Importantly, new variables have been created whereas others have been removed 
# during the transformation process.
# Double-check that all variables are assigned to the appropriate class.
str( CountMatrix_Combined_Melt )

# If we want to modify animal species class:
CountMatrix_Combined_Melt$Animal <- as.character( CountMatrix_Combined_Melt$Animal )

# It is imperative that you fully understand the importance of the transformation 
# you just performed (i.e., going from wide to long format).
# Each row in your new data frame contains a single Animal_Count measurement.
# This means that each "Camera_ID" now has 4 unique rows with a count value for each of 
# the 4 animals (instead of the original 1 row per Camera_Id).
# Thus, the values of each variable in the id.vars argument are now 
# repeated 4 times.
# This ensures that all information contained in the Wide format data are still provided 
# for each row of the Long format data (which now has many more rows).

# How do we work out how many rows in the long vs wide format?
dim( CountMatrix_Combined_Melt ); dim(CountMatrix_Combined )


# Working with data in Long format ------------------------------------------------

# Now that the data are Tidy, we can produce additional variables that utilize the 
# new data structure.

# For example, say we want to add the scientific name for each animal as a new variable.
# (Sage-Grouse (Centrocerus urophasianus), Rabbit (Brachylagus idahoensis), 
# Rattlesnake (Crotalus oreganus), Falcon (Falco peregrinus)).

# We would normally import a data frame with scientific names and join it to ours.
# Or, we could code it manually. 
# We start by working out how many species we need common names for. 
scinames <- data.frame( Animal = unique( CountMatrix_Combined_Melt$Animal ), 
          # We also create a column with missing values to add scientific names to. 
          Scientific_Name = rep( NA, length( unique( CountMatrix_Combined_Melt$Animal)) ))
# Check 
scinames

# Now replace with correct scientific names in the correct order:
scinames$Scientific_Name <- c( "Centrocerus urophasianus", "Brachylagus idahoensis", 
                          "Crotalus oreganus", "Falco peregrinus" )
# Check again
scinames

# You can now join your name data frame to your long format data frame.
# We start by checking dimensions of original:
dim( CountMatrix_Combined_Melt )

# Now we join.
CountMatrix_Combined_Melt <- left_join( CountMatrix_Combined_Melt, scinames, by = "Animal" )

# Check that it worked.
head( CountMatrix_Combined_Melt ); dim( CountMatrix_Combined_Melt )
# Can you see how we expect the outcome to be the same number of rows as CountMatrix_Combined_Melt?    

# Add a new variable for the relative observed occupancy (assuming perfect detection) 
# of each animal observed out of the total counts from each "Camera_ID".
CountMatrix_Combined_Melt$Relative_Occupancy <- CountMatrix_Combined_Melt$Animal_Counts / CountMatrix_Combined_Melt$Total_Counts

# Did it work?
head( CountMatrix_Combined_Melt)


########## Save everything you need  ------------------------------

# Save the wide data frame as a .csv file.
write.csv(CountMatrix_Combined, "Data/CountMatrix_Combined.csv", row.names = FALSE)

# Save the long data frame as a .csv file.
write.csv(CountMatrix_Combined_Melt, "Data/CountMatrix_Combined_Melt.csv", row.names = FALSE)

# Save your workspace.
save.image( "Workspaces/Data_Transformation_Workspace.RData" )


##### -------------------------------------------------------------------------------

### Next Tutorial: "Data Visualization"

###################### END OF SCRIPT ##################################################