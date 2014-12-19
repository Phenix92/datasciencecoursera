## Load libraries
library(data.table)

## ------------------------
## FUNCTIONS
## ------------------------
readFeaturesLabel <- function(dataDirectory) {
  ## 'filename' is the filename containing features list
  ## Return a data frame containing all features
  
  features <- fread(paste(dataDirectory, "features.txt", sep = ""), header = F, sep = " ")
  setnames(features, c("Index", "Label"))
  features
}

readSet <- function(filename, features) {
  ## 'filename' is the filename containing data set
  ## Return a data frame containing all data of the file
  
  data <- read.table(filename, colClasses="numeric", comment.char="")
  setnames(data, features$Label)
}

readSetActivity <- function(filename) {
  ## Read file containing label for each row
  ## 'filename' is the filename to read
  
  labels <- read.table(filename, colClasses="numeric", comment.char="")
  setnames(labels, c("Activity"))
}

readActivityLabels <- function(dataDirectory) {
  labels <- read.table(paste(dataDirectory, "activity_labels.txt", sep = ""))
  setnames(labels, c("Key", "Label"))
}

readSubject <- function(filename) {
  ## Read file containing subject for each row
  ## 'filename' is the filename to read
  
  subjects <- read.table(filename, colClasses="numeric", comment.char="")
  setnames(subjects, c("Subject"))
}

mergeColumns <- function(dfSet, dfActivity, dfSubject) {
  merged <- cbind(dfSubject$Subject, dfActivity$Activity, dfSet)
  setnames(merged, c("Subject", "Activity", names(dfSet)))
  merged
}

readCompleteDF <- function(dataDirectory, type, features) {
  dataSet <- readSet(paste(dataDirectory, type, "/X_", type, ".txt", sep = ""), features)
  activitySet <- readSetActivity(paste(dataDirectory, type, "/y_", type, ".txt", sep = ""))
  subjectSet <- readSubject(paste(dataDirectory, type, "/subject_", type, ".txt", sep = ""))
  merged <- mergeColumns(dataSet, activitySet, subjectSet)
  merged
}

## ------------------------
## MAIN
## ------------------------

## Parent directory containing all data files
parentDataDirectory <- "UCI HAR Dataset/"

# Get features labels
features <- readFeaturesLabel(parentDataDirectory)

## Construct complete data frame for test data
testDF <- readCompleteDF(parentDataDirectory, "test", features)
## Construct complete data frame for train data
trainDF <- readCompleteDF(parentDataDirectory, "train", features)

## Merge test and train data frames
globalDF <- rbind(trainDF, testDF)

## Get activity labels
activityLabels <- readActivityLabels(parentDataDirectory)
globalDF$Activity <- as.factor(globalDF$Activity)
levels(globalDF$Activity) <- activityLabels$Label

# Filter global DF with only necessary columns
MeanOrStdColumns <- features$Label[grepl("mean\\(", features$Label) | grepl("std\\(", features$Label)]
studyDF <- subset(globalDF, select = c("Subject", "Activity", MeanOrStdColumns))

## Split data frame by activity and subject
splitted <- split(studyDF, list(studyDF$Activity, studyDF$Subject))

## Compute mean for each studied variable
tidySet <- lapply(splitted, function(x) colMeans(x[,3:ncol(studyDF)]))

## Transform result into data frame
tidySet <- as.data.frame(do.call(rbind, tidySet))

## Get index of point ponctuation in row names of the tidy set
indexOfPointInRowNames<-sapply(rownames(tidySet), function(x) regexpr(pattern="\\.", x))

## List Activity names
Activity <- substring(text = rownames(tidySet), first=1, last=indexOfPointInRowNames-1)

## List subject IDs
Subject <- as.numeric(substring(text = rownames(tidySet), first=indexOfPointInRowNames+1, last=nchar(rownames(tidySet))))

## Add activity name and subject ID
tidySet <- cbind(Activity, Subject, tidySet)

## Remove all variables except tidy set (=result of the study)
rm(list=ls()[ls()!="tidySet"])
