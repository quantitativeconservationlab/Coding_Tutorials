################################################################################
# This tutorial was created by Jonas Frankel-Bricker and Jen Cruz as Part 3 of the 
# "Basic_R" tutorial series.  
# "Data_Visualization.R" will walk you through the basics of constructing and 
# and customizing data visualization using the package ggplot2.
################################################################################


# Background #################################
# "Data Visualization" refers to the process of presenting data through visual 
# representations.
# Different data types can be visualized with a wide variety of plots and graphs.
# In this tutorial we will be using the information stored in the data frame 
# produced in Part 2 (CountMatrix_Combined_Melt.csv).
# Specifically, basic usage of functions in the "ggplot2" package will be explored
# and implemented to create a box plot of some of these data.
# This tutorial serves as an introduction to this widely used package.
# For more in-depth explanations of the functionality of ggplot2, please see:
# http://r-statistics.co/Complete-Ggplot2-Tutorial-Part1-With-R-Code.html
# In addition, please download the "Data Visualization with ggplot2 Cheat Sheet"
# located at: https://rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf

# To begin this tutorial, follow the "Initial preparation" steps from Part 1 to clear 
# the workspace, release the computer's memory, and set the appropriate working directory.
# Next, create and save a new script.

# Load the required packages.
library(ggplot2) # ggplot2 is also included as part of the "tidyverse" suite of packages

# Import the clean, tidy data frame produced from Part 2.
CountMatrix_Combined_Melt <- read.csv("Data/CountMatrix_Combined_Melt.csv")

# Make sure variables are assigned to the appropriate class.
str(CountMatrix_Combined_Melt)

CountMatrix_Combined_Melt$Camera <- as.factor(CountMatrix_Combined_Melt$Camera)
CountMatrix_Combined_Melt$Total_Counts <- as.numeric(CountMatrix_Combined_Melt$Total_Counts)
CountMatrix_Combined_Melt$Animal_Counts <- as.numeric(CountMatrix_Combined_Melt$Animal_Counts)
# Note how importing the previously saved .csv file does not always conserve the 
# appropriate variable classes.

# ggplot2 data requirements and coding syntax ################################# 

# ggplot2 is a robust data visualization package that is often used to create
# publication-quality plots for different kinds of data.
# Importantly, the package uses a unique syntax that often deviates from base R
# coding.
# Further, input data usually needs to be in long (tidy) format, so that each column
# contains values for a single variable type.  

# First, it is imperative to understand the core of a line of code in ggplot2.
# MOST plots are created by first using the function ggplot().
# This function designates the first argument as the data used to source the 
# variables and values that will be plotted.
# The second argument assigns variables to the x- and y-axes of the plot using the
# aes() function.

# Let's begin to construct a plot representing the number of counts for each animal
# (Animal_Counts).
# Notice how the output creates a plot in the "Plots" tab in the bottom right pane.
# ggplot2 automatically ordered the site names on the x-axis and chose a range of 
# values for the y-axis.
# However, no data was plotted using this initial code because we did not choose 
# which kind of plot should be constructed.
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts) )
# Since this line is the core foundation for ggplot2, it is often save as an object
# and then built upon with additional plotting parameters.
animal_boxplot <- ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts) )

# Let's build a box plot (box and whisker) by adding the geom_boxplot() function 
# to our code.
# Importantly, subsequent functions in ggplot2 are added using the plus (+) sign, 
# while functions used in arguments are separated by a comma (,).
animal_boxplot + geom_boxplot()
# A basic box plot has been constructed.
# The upper and lower edges of the boxes represent quartiles around the mean, 
# while bold lines represent median values.
# Box plots are useful because they provide information on the variation of the data.
# What experimental questions could be addressed with this visualization?
# What other information from our data could be added to provide a more informative
# plot? 

# Our basic box plot provides useful information, however, it does not currently show
# the actual data being summarized by the boxes (i.e counts for each specific 
# animal for each site).
# You can add additional information to plots by adding colors to the ggplot() 
# function.

# For this example, lets make the same plot, but add a "color" argument for "Animal".
# Note how "color" is assigned as an argument in the aes() function.  This renders
# the previous "animal_boxplot" object defunct.
# It is often beneficial to write the whole line of ggplot2 code.
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() 
# Adding the additional information of each site helps to clarify the data being
# visualized.

# Although our plot is now more informative, we still don't have visual information
# on the number of observations (i.e. counts for each camera for each animal at each site).
# Let's add the points used to create the box plots. 
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point()
# Each point represents the number of counts for each animal from each camera at 
# each site.
# However, you can see that the points are not overlapping with their associated 
# box plots.  
# Most plotting functions have many associated arguments that can modify the output.
# One of the most common arguments is "position", which allows for modification of 
# the orientation in which plots are presented.
# Here, we define the position of the points using the position_jitterdodge() function.
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point(position = position_jitterdodge(jitter.width = 0))
# The points are now aligned correctly.
# However, not all cameras are visualized, since some of the points overlap 
# (i.e. different cameras that had the same number of counts for a given animal).
# You can spread the points by increasing the value of the "jitter.width" argument.
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point(position = position_jitterdodge(jitter.width = 0.1))

# The axes initially provided by ggplot2 often need to be changed.
# Here, lets make the y-axis range from 0 to 9 with every 3 tick marks represented 
# by their appropriate number using the scale_y_continuous() function.
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point(position = position_jitterdodge(jitter.width = 0.1))
# It is often beneficial to add some extra space at the top of the plot to provide 
# room for statistical annotation or other information.

# Importantly, a ggplot can be stored as an object at any time.
# Remember, only code that you store as an object can be easily saved.
AnimalCount_Box <- 
  ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point(position = position_jitterdodge(jitter.width = 0.1))
# The new object is now stored in the Data pane as a "list".
# Click on the object.
# What do you think the different components represent?

# A commonly used modification is changing the labels of the x- and y-axes and
# providing a title.
# Add new names to the axes using the xlab() and ylab() functions and assign a 
# title with the ggtitle() function.
AnimalCount_Box <- 
  AnimalCount_Box + 
  xlab( "Animal Type" ) + 
  ylab( "Site Counts" ) +
  ggtitle( "Animal Site Counts" )

AnimalCount_Box

# Save plots as .rds files using the saveRDS() function.
saveRDS( AnimalCount_Box, "Data/AnimalCount_Box.rds" )

# Import plots using the readRDS() function.
AnimalCount_Box <- readRDS( "Data/AnimalCount_Box.rds" )









