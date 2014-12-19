## This Code Book describes the R script "run_analysis.R"
## This script is for the MOOC "Getting and Cleaning Data" in coursera

The working directory must contain the directory "UCI HAR Dataset".

The script is splitted in many functions.
The functions have to construct the global data frame containing all data.
There are sub functions to construct sub data frames (one for test set and one for train set).
After this, we extract only necessary data and compute mean for each variable.
At the end, we format the result and keep the last variable : tidySet