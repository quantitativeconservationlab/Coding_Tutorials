################################################################################
# This tutorial was created by Jonas Frankel-Bricker and Jen Cruz as Part 3 of the 
# "Basic_R" tutorial series.  
# "Data_Visualization.R" will walk you through the basics of constructing and 
# and customizing data visualizations using the package ggplot2.
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
library( tidyverse ) # ggplot2 is included as part of the "tidyverse" suite of packages
#alternatively you could load only the packages that you will be using separately:
# library( ggplot2 )
# library( lubridate ) #this package is great for handling dates easily

# Import the clean, tidy data frame produced from Part 2.
CountMatrix_Combined_Melt <- read.csv("Data/CountMatrix_Combined_Melt.csv")

# Make sure variables are assigned to the appropriate class.
str(CountMatrix_Combined_Melt)

#remember camera is just an ID so we assign it as a factor
CountMatrix_Combined_Melt$Camera <- as.factor(CountMatrix_Combined_Melt$Camera)
CountMatrix_Combined_Melt$Total_Counts <- as.numeric(CountMatrix_Combined_Melt$Total_Counts)
CountMatrix_Combined_Melt$Animal_Counts <- as.numeric(CountMatrix_Combined_Melt$Animal_Counts)
# Note how importing the previously saved .csv file does not always conserve the 
# appropriate variable classes.

# ggplot2 data requirements and coding syntax ################################# 

# ggplot2 is a robust data visualization package that is often used to create
# publication-quality plots.
# Importantly, the package uses a unique syntax that often deviates from base R
# coding.
# Further, input data usually needs to be in long (tidy) format, so that each column
# contains values for a single variable type.  

# It is imperative to understand the foundation of a line of code in ggplot2.
# MOST plots are created by starting with the function ggplot().
# This function designates the first argument as the data used to source the 
# variables and values that will be plotted.
# The second argument assigns variables to the x- and y-axes of the plot using the
# aes() function.

# Let's begin to construct a plot representing the number of counts for each animal
# (Animal_Counts).
ggplot( data = CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts) )
# Notice how the output creates a plot in the "Plots" tab in the bottom right pane.
# ggplot2 automatically ordered the site names on the x-axis and chose a range of 
# values for the y-axis.
# However, no data was plotted using this initial code because we did not choose 
# which kind of plot should be constructed.
# Since this line is the core foundation for ggplot2, it is often saved as an object
# and then built upon with additional plotting functions and parameters.
#let's do that:
animal_plot <- ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts) )

#What ways of visualizing our count matrix would be useful as preliminary checks?

# We could start by looking at the distribution of our data using box plots.
# Let's build a box plot (box and whisker) by adding the geom_boxplot() function 
# to our code.
# Importantly, subsequent functions in ggplot2 are added using the plus (+) sign, 
# while arguments are separated with a comma (,).
animal_plot + geom_boxplot( )
# A basic box plot has been constructed.
# The upper and lower edges of the boxes represent quartiles around the mean, 
# while the bold horizontal lines represent median values.
# Box plots provide information on the spread, distribution, mean, variance 
# and possible outliers for different groups in our dataset.
# What experimental questions could be addressed with this visualization?
# What other information from our data could be added to provide a more informative
# plot? 

# Our basic box plot provides useful information, however, it does not  show
# the data points being summarized by the boxes (i.e counts for each specific 
# animal for each site).
# You can add additional information to plots by adding colors to the ggplot() 
# function.

# For this example, lets make the same plot, but add a "color" argument for "Animal".
animal_plot +  geom_boxplot( aes(color = Site_Name) ) 
# Note how "color" is assigned as an argument in the aes() function inside the geom_plot()
# so you can change the variables that you are calling within the functions themselves:

# Adding the additional information of each site helps to clarify the data being
# visualized.

# Although our plot is now more informative, we still don't have visual information
# on the number of observations (i.e. counts for each camera for each animal at each site).
# Let's add the points used to create the box plots. 
# Since we need to group by color for both the points and the boxplots we write the 
# entire function again instead of calling the one we save previously:
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point()
# You can see that the points are not overlapping with their associated 
# box plots.  
# Most plotting functions have many arguments that can modify the output.
# One of the most common arguments is "position", which allows for modification of 
# the orientation in which plots are presented.
# Here, we define the position of the points using the position_jitterdodge() function.
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, 
            color = Site_Name) ) +
  geom_boxplot() +
  geom_point( position = position_jitterdodge(jitter.width = 0) )
# The points are now aligned correctly.
# However, not all cameras are visualized, since some of the points overlap 
# (i.e. different cameras that had the same number of counts for a given animal).
# You can spread the points by increasing the value of the "jitter.width" argument.
ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point( position = position_jitterdodge(jitter.width = 0.1) )

# We are now happy with how the data are displayed we can save the plot by assigning
# it to an object like we did previously 
# A ggplot can be stored as an object at any time.
# Remember, only code that you store as an object can be easily saved.

animal_boxplot <- ggplot( CountMatrix_Combined_Melt, aes( x = Animal, y = Animal_Counts, color = Site_Name) ) +
  geom_boxplot() +
  geom_point( position = position_jitterdodge(jitter.width = 0.1) )
# The new object is now stored in the Data pane as a "list".
# Click on the object.
# What do you think the different components represent?

# if we want to view, we can also just call it:
animal_boxplot

# We can then modify how it is displayed by building on it like we have been doing. 
# One common modification is altering the axes
# Here, lets make the y-axis range from 0 to 9 with 4 evenly spaced tick marks 
# represented by their appropriate value using the scale_y_continuous() function.
animal_boxplot +  scale_y_continuous( limits = c(0, 9), breaks = c(0, 3, 6, 9) )
# It is often beneficial to add some extra space at the top of the plot to provide 
# room for statistical annotation or other information.


# Another common modification is changing the labels of the x- and y-axes and
# providing a title.
# Add new names to the axes using the xlab() and ylab() functions and assign a 
# title with the ggtitle() function.
animal_boxplot <- animal_boxplot + 
  xlab( "Animal Type" ) + 
  ylab( "Site Counts" ) +
  ggtitle( "Animal Site Counts" )

#view
animal_boxplot

# You can also use preset themes
animal_boxplot + theme_bw()
#or
animal_boxplot + theme_classic()

#you can also increase font size for all items on the plot and shift legend location
animal_boxplot + theme_classic(base_size = 15) + 
  theme( legend.position = "bottom" )
# Did you notice our titles dissapeared? That is because the order in which we call our 
# functions in ggplot matters. Here we had relabeled and the we accidentally overwrote them by setting our 
# classic theme. So we need to modify the order in which we provide these arguments.
# We now save our last plot that we are happy with. 
# Notice additional tweeks to the look of the plot in each line:
animal_boxplot <- animal_boxplot + # we replace the latest plot
  theme_classic( base_size = 15 ) + # we call preset theme and increase font size for all elements
  ggtitle( "Animal Site Counts" ) + # we add title after calling the preset theme 
  labs( color = "Sites", # Here is another way of relabeling 
        x = "Animal Type", #see how we can label our x axes here instead of xlab()?
          y = "Site Counts" ) + 
theme( legend.position = "bottom", # we modify the location of the legend
       plot.title = element_text( hjust = 0.5 ) )  # we center the plot title
#view
animal_boxplot

# What other types of plots can we produce with our data?
# What about evaluating how occupancy of our species changed with time?

# to deal with dates we use lubridate to create a new column where our Date, 
# which is currently in character format turns into date format
CountMatrix_Combined_Melt$PrettyDate <- lubridate::as_date( CountMatrix_Combined_Melt$Date )

#check 
head( CountMatrix_Combined_Melt ) 
# it looks the same but when you dive deeper:
str( CountMatrix_Combined_Melt )

# to get a quick idea of how occupancy changed with time for each species we 
# could get the mean value across our camera traps and plot those
# Since we don't need the means for anything other than plotting we can combine 
# the power of piping %>% with that of ggplot 
# Here we call our dataframe, group it and create summary data 
# Remember doing this in the Data_Transformation.R script?
CountMatrix_Combined_Melt %>%
  group_by( Animal, PrettyDate ) %>%
  summarise( Occupancy = mean( Relative_Occupancy ) ) 
#Note that you aren't saving the output anywhere. It should just display on your
# console so that you can check you have done it correctly

#If so then you can use this temporary summary and input it into ggplot as follows: 
CountMatrix_Combined_Melt %>%
  group_by( Animal, PrettyDate ) %>%
  summarise( Occupancy = mean( Relative_Occupancy ) ) %>%
  #note here that we replace where our data goes in the ggplot function below with a full stop:
ggplot( . , 
        #now we can call the new variable that we created along with those that 
        # were used to group our data, which are still stored in our new, unsaved dataframe
        aes( x = PrettyDate, y = Occupancy, color = Animal ) ) +
  geom_line( size = 1.5 ) + # add lines for tracing occupancy for each species and increase their thickness
  geom_point( size = 3 ) + # add points for these data and increase point size
theme_classic( base_size = 15 ) + # #add our preset classic theme
labs( x = "Sampling date", #relabel 
      y = "Mean occupancy",
      color = "Species" )
# If you like this plot you need to save it as an object

#But what if you are interested in how much variability you saw with time, rather 
# than just focusing on the mean? You can use your original dataframe and create 
# smoothed lines that average across your data and include variance within ggplot:
ggplot( CountMatrix_Combined_Melt, 
        aes( x = PrettyDate, y = Relative_Occupancy, color = Animal ) ) +
          geom_smooth() + #here we create the smoothed mean with confidence intervals
          geom_point() #here we plot the raw data to check that our model provides a good fit
#We leave you to modify the labels, theme, sizes etc based on what you learnt 
# previously

######### saving relevant objects and data ---------------------------------

# save plot with ggsave to define file type, resolution and plot dimensions:
ggsave("Data/AnimalCount_Box.png", dpi=500, height=4, width=5, units="in" )

# You can also save plots as .rds files using the saveRDS() function.
saveRDS( animal_boxplot, "Data/AnimalCount_Box.rds" )

# Import plots using the readRDS() function.
AnimalCount_Box <- readRDS( "Data/AnimalCount_Box.rds" )

# What other plots do you want to save? 

######################## END OF SCRIPT ##########################################