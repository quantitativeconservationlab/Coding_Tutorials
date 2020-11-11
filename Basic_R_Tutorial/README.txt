The “Basic_R” tutorial serves as an introduction to creating an R project, organizing project directories, importing experimental data, performing initial data cleaning, transforming data, conducting statistical analyses, and constructing data visualizations.  This “README” text file provides a description on how to set up an R project for use in this tutorial.  

Before you work in R (or any other computer program), it is imperative to understand “Path”.  Generally speaking, Path is a string of text specifying a particular location on your computer.  Although  the “syntax” (the format it is written) for Path slightly differs between MacOS and Windows, the concept is the same.  Understanding Path is required when coding, since you must always know where in your computer’s digital space you are working and where your work is being saved.

1) Create a new folder (also known as a “directory”) on your computer named “Tutorials”.  
	- For the purpose of this example, create this folder on your computer’s “Desktop” by right-clicking on your computer’s background and selecting “New Folder”. 

2) Create an R Project in the “Tutorials” directory.  
	- Open RStudio, click on the “File” tab at the top left of the screen, and select “New Project” from the dropdown menu.  
	- Click “New Directory” and “New Project” in the subsequent windows.  
	- Finally, name the directory “Basic_R” in the “Directory name” section and click the “Browse” button next to the “Create project as a subdirectory of” section. 
	- Navigate to the “Tutorials” folder you created on your desktop.  This will select the “Path” where the R Project’s directory will be saved.  

*** Creating a new R Project builds a physical directory located in the Path you set in the previous step.  Initially, the directory has only the .Rproj file.  However, all scripts you write for the project will be saved to this directory in addition to data and outputs of your code.  It is important that you know the exact location of this R Project and its contents.  Only work on components directly-associated with the R Project you are coding in.***

3) Create a new subdirectory in your R Project’s directory by right-clicking and creating a new folder named “Data”.  Place the data file “CountMatrix.csv” in the newly created “Data” folder.  

You have created the basic infrastructure of an R project, composed of a General directory “Tutorials”, the R Project’t directory “Basic_R”, and a subdirectory in the R Project “Data” containing your experimental data.  The Paths for each of these components are as follows:

“Tutorials” (general directory):
Mac: “/Users/YourUserName/Desktop/Tutorials”
PC: “C:\Users\YourUserName\Desktop\Tutorials”

“Basic_R” (R Project directory):
Mac: “/Users/YourUserName/Desktop/Tutorials/Basic_R”
PC: “C:\Users\YourUserName\Desktop\Tutorials\Basic_R”

“Data” (R Project subdirectory containing experimental data):
Mac: “/Users/YourUserName/Desktop/Tutorials/Basic_R/Data”
PC: “C:\Users\YourUserName\Desktop\Tutorials\Basic_R\Data”

“CountMatrix.csv” (experimental data):
Mac: “/Users/YourUserName/Tutorials/Basic_R/Data/CountMatrix.csv”
PC: “C:\Users\YourUserName\Desktop\Tutorials\Basic_R\Data\CountMatrix.csv”

You will now transition to working in your R Project.  For this tutorial, you are provided with the R Script “Data_Cleaning.R”.  Transfer this file to your R Project’s directory.  To open this script, double-click on your R Project file “Basic_R.Rproj” to open RStudio.  In the bottom-right of the window, you will see all files located within your R Project.  Click on the “Data_Cleaning.R” script to begin the tutorial.   

Other useful R tutorial resources:
Becoming familiar with tidyverse, data manipulation, and data visualization:
https://r4ds.had.co.nz/

Converting data between wide and long format: 
http://www.cookbook-r.com/Manipulating_data/Converting_data_between_wide_and_long_format/

data visualization in R:
http://satrdayjoburg.djnavarro.net/

spatial data:
https://geocompr.robinlovelace.net/spatial-class.html#crs-intro

lubridate for working with dates: 
https://cran.r-project.org/web/packages/lubridate/vignettes/lubridate.html











