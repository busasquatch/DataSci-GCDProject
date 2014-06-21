#Script assumes that SAMSUNG files are downloaded from 
#the zip file and unzipped.  When the files unzipped, a 
#directory named 'UCI HAR Dataset' is created.  Script
#assumes the current directory contains the 'UCI HAR Dataset'
#directory.  This commented code will download and unzip
#the necessary files to the active directory.

# temp <- tempfile()
# url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# 
# #download
# download.file(url,temp)
# 
# #unzip
# unzip(temp)

##################################
##BEGIN File names
##################################
#x tables are the measurements
filename.x_test <- "./UCI HAR Dataset/test/X_test.txt"
filename.x_train <- "./UCI HAR Dataset/train/X_train.txt"

#y tables are the type of test and JOIN to activity_labels.txt
filename.y_test <- "./UCI HAR Dataset/test/y_test.txt"
filename.y_train <- "./UCI HAR Dataset/train/y_train.txt"

#subject tables are the PK identifying each of the 30 subjects
filename.subject_test <- "./UCI HAR Dataset/test/subject_test.txt"
filename.subject_train <- "./UCI HAR Dataset/train/subject_train.txt"

#column names for measurements in x_test and x_train
filename.features <- "./UCI HAR Dataset/features.txt"

#lookup table for y_[test|train] tables
filename.activity.labels <- "./UCI HAR Dataset/activity_labels.txt"
##################################
##END File names
##################################

##################################
##BEGIN File reads
##################################
#read measurement tables
test.measures <- read.table(filename.x_test, header = FALSE)
train.measures <- read.table(filename.x_train, header = FALSE)

#read type of test tables
test.activity <- read.table(filename.y_test, header = FALSE)
train.activity <- read.table(filename.y_train, header = FALSE)

#read the primary key identifying the subject from which
#measurements were made
test.subject <- read.table(filename.subject_test, header = FALSE)
train.subject <- read.table(filename.subject_train, header = FALSE)

#read features, which are the column names of x_test
features <- read.table(filename.features, header = FALSE)

#read activity labels
activity.type <- read.table(filename.activity.labels, header = FALSE)
##################################
##END File reads
##################################

##################################
##BEGIN Column names
##################################
#give the features table meaningful column names
names(features) <- c("featureId","feature")

#assign the features list to the column names of [test|train].measures
names(test.measures) <- features[,2]
names(train.measures) <- features[,2]

#give the subject tables a meaningful column heading
names(test.subject) <- "subject"
names(train.subject) <- "subject"

#give the activity tables a meaningful column heading
names(test.activity) <- "activityId"
names(train.activity) <- "activityId"

#give the activity type table meaningful column headings
names(activity.type) <- c("activityId","activity")
##################################
##END Column names
##################################
##################################
##BEGIN Data Frame Building
##################################
#Use join() form the plyr package to merge datasets
#don't use merge() because file gets resorted, even if sort argument is set to FALSE
library(plyr)
#add the descriptive activity names to both the test and train 
#activity dataframes
test.activity <- join(x = test.activity, y = activity.type
                      ,by = "activityId", type = "left" )
train.activity <- join(x = train.activity, y = activity.type
                       ,by = "activityId", type = "left" )


#at this point, activity.type can be removed from memory
rm(activity.type)

#put the test subjects, activity, and measures in one dataframe, add a column
#to identify these as the test set
test.measures <- cbind(set = "test", test.subject, test.activity, test.measures)


#put the train subject, activity, and measures in one dataframe, add a column
#to identify these as the train set
train.measures <- cbind(set = "train", train.subject, train.activity, train.measures)

#********************************************************
#BEGIN MILESTONE #1
#Merge the training and test sets to create one data set
#********************************************************
#create a single measures table, combining test and train
measures <- rbind(test.measures, train.measures)
#********************************************************
#END MILESTONE #1
#********************************************************
#at this point, the base test and train tables can be removed 
#from the parent environment
rm(test.subject)
rm(test.activity)
rm(test.measures)
rm(train.subject)
rm(train.activity)
rm(train.measures)

#********************************************************
#BEGIN MILESTONE #2
#Extract only the measurements on the mean and standard dev
#for each measurement
#********************************************************
#Objective is to create a dataframe with 
#set
#subject
#activityId
#activity
#all measurements containing the string "mean()"
#all measurements containing the string "std()"

#the column names in [measures] are
#1:4 - set, subject, activityId, activity 
#5:565 - freature names of measurements
#we want to keep 1:4, and any of 5:565 where the string
#mean() or std() is found

#create a logical vector containing TRUE for the first four elements, and TRUE for any column name in measures (columns 5 - 565 only) that contain the string 'mean()' or 'std()'.  These are the columns that will be subsetted into a dataframe
columns.to.keep <- c(rep(TRUE,4), grepl("std|mean[\\(\\)]", names(measures[5:565])))

#subset all rows of measures dataframe for only those columns in which columns.to.keep is TRUE
data <- measures[, c(columns.to.keep)]

##dataframes measures and features can be released from memory
rm(measures)
rm(features)

#********************************************************
#END MILESTONE #2
#********************************************************
#********************************************************
#BEGIN MILESTONE #3
#use descriptive acitivity names to name the activities
#in the dataset
#********************************************************
#this milestone was completed during dataframe building
#prior to milestone 1.
#********************************************************
#END MILESTONE #3
#********************************************************

#********************************************************
#BEGIN MILESTONE #4 and 5
# Apprpirate label the data set with descriptvie variable names
#********************************************************
#load the reshape2 package
library(reshape2)

#use melt() to produce a molten dataset
#will create a six variable datasest
#columns are set, subject, activityId, activity, variable (the measure), value (the measurement)
data.molten <- melt(data, id = c(names(data)[1:4]), measure.vars = c(names(data)[-c(1:4)]))


##############################
#BEGIN Step 1
#put the feature in it's own column and make it a factor
##############################
#make the variable being split of class character
data.molten$variable <- as.character(data.molten$variable)
#split the long feature name by hyphen, which creates a list
split.variable <- strsplit(data.molten$variable, "\\-")
#create a firstElement function
firstElement <- function(x) {x[1]}
#iterate through the list and put the first element into a new column in the dataframe.
data.molten$feature <- sapply(split.variable, firstElement)
#convert this new column to a factor
data.molten$feature <- as.factor(data.molten$feature)
##############################
#END Step 1
##############################
##############################
#BEGIN Step 2
#put the mean or std in it's own column
##############################
#using split.variable list created in step 1
#create function to extract second element of each list element
secondElement <- function(x) {x[2]}
#iterate through the list and put the third element into a new column in the dataframe.
data.molten$valueType <- sapply(split.variable, secondElement)
#get rid of the parentheses in this new variable
data.molten$valueType <- sub("\\(\\)$", "", data.molten$valueType)
#rename std as sd
data.molten$valueType <- sub("[s]t[d]", "sd", data.molten$valueType)
##############################
#END Step 2
##############################
##############################
#BEGIN Step 3
#put axial direction in own column
##############################
thirdElement <- function(x) {x[3]}
#iterate through the list and put the third element into a new column in the dataframe.
data.molten$axialDirection <- sapply(split.variable, thirdElement)
data.molten$axialDirection <- as.factor(data.molten$axialDirection)
##############################
#END Step 3
#put axial direction in own column
##############################

#now that we have feature, valueType, and axialDirection in the own column the
#dataset can be cast to put the value under mean or sd, depending on the type
#of measurement.
#First step is to subset the dataframe to get rid of the original varaible
#column, which was split up into feature, valueType, and axialDirection

#Next, cast (i.e. widen) the data into a new dataframe
#take the mean of valueType (mean and sd) grouping by subject, activity, feature, and axialDirection,  
tidy.data <- dcast(data.molten, subject + activity + feature + axialDirection ~ valueType, fun.aggregate = mean )

#since the mean was taken, give the mean and sd columns meaningful names
names(tidy.data)[5:6] <- c("averageMean", "averageSD")

## other data frames can be removed
rm(data.molten)
rm(data)
rm(split.variable)

#output to file
write.table(tidy.data, file = "./tidydata.txt", sep = "\t", row.names = FALSE )

#********************************************************
#END MILESTONE 4 and 5
#********************************************************