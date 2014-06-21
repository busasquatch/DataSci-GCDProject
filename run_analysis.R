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
##BEGIN Load Required Packages
##################################
library(plyr)
library(reshape2)
##################################
##END Load Required Packages
##################################

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

##########################################################
##BEGIN Column names
#This section starts to meet Milestone 4,
#which is to give variables meaningful
#column names.  This process continues
#througout the script.

#As read, all column headers are currently in the 
#format 'V#', where # is a number indicating the column
#number.
##########################################################
#give the features table meaningful column names
names(features) <- c("featureId","feature")

#assign the elements of features column 2 (the feature description)
#to the column names of [test|train].measures
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
##BEGIN Building a Single Dataset
#1. Join the test dataframes together
#2. Join the train dataframes together
#3. Join the test and train dataframes.
##################################
#Use join() form the plyr package to merge datasets
#don't use merge() because file gets resorted, even 
#if sort argument is set to FALSE

#Substep 1
#Add the activity description to the test activity dataframe
#match on activityId
test.activity <- join(x = test.activity, y = activity.type
                      ,by = "activityId", type = "left" )

#Substep 2
#Add the activity description to the train activity dataframe
#match on activityId
train.activity <- join(x = train.activity, y = activity.type
                       ,by = "activityId", type = "left" )

#Substep 3
#put the test subjects, activity, and measures in one dataframe, add a column
#to identify these as the test set
test.measures <- cbind(set = "test", test.subject, test.activity, test.measures)

#Substep 4
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

###BEGIN Garbage Collection
#release objects from memory
rm(activity.type)
rm(test.subject)
rm(test.activity)
rm(test.measures)
rm(train.subject)
rm(train.activity)
rm(train.measures)
###END Garbage Collection

##################################
##END Building a Single Dataset
##################################

################################################
##BEGIN Extracting mean and standard deviation
#Objective is to create a dataframe with 
#-set
#-subject
#-activityId
#-activity
#-all measurements containing the string "mean()"
#-all measurements containing the string "std()"
################################################

#the column names in [measures] are
#1:4 - set, subject, activityId, activity 
#5:565 - freature names of measurements
#keep 1:4, and any of 5:565 where the string
#mean() or std() is found

#create a logical vector containing TRUE for the first 
#four elements, and TRUE for any column name in measures
#(columns 5 - 565 ) that contain the string 'mean()' 
#or 'std()'.  These are the columns that will be subsetted 
#into a dataframe
columns.to.keep <- c(rep(TRUE,4), grepl("std|mean[\\(\\)]", names(measures[5:565])))

#********************************************************
#BEGIN MILESTONE #2
#********************************************************
#subset all rows of measures dataframe for only those columns in which 
#columns.to.keep is TRUE
data <- measures[, c(columns.to.keep)]
#********************************************************
#END MILESTONE #2
#dataframe [data] is contains all mean() and std() 
#measurements.
#data has 10299 observations and 70 variables
#********************************************************

#BEGIN Garbage Collection
#release objects from memory
rm(measures)
rm(features)
#END Garbage Collection
################################################
##END Extracting mean and standard deviation
################################################

################################################
##BEGIN Tidying the dataset
#This section meets milestones 3, 4, and 5,
#Make sure all variable names are descriptive.
#Resahpe data for aggregation
#although work towards milestone 3 has been done
#throughout the script.
################################################
#use melt() (reshape2 package) to produce a molten dataset
#Will transform a dataset of 10299 observations and 70 variables
#into a dataset of 679734 observations and 6 variables 
#this pivots the dataset on set, subject, activityId, activity
#and creates observations for each measure (value) and measurement (feature)
data.molten <- melt(data, id = c(names(data)[1:4]), measure.vars = c(names(data)[-c(1:4)]))


####################################################################
#BEGIN Tidying the dataset: Feature Desciptives Transformations
#At this point, the feature desciptions are a concatenation
#of the feature, the measurement type (mean or standard deviation),
#and the axial Direction.  This section splits these three
#items into their own variable.
####################################################################
#Substep 1
#put the feature type in it's own column
#make the variable being split of class character
data.molten$variable <- as.character(data.molten$variable)

#split the  feature name by hyphen, which creates a list
#of 679,734 elements, each with 2 or 3 elements representing
#the feature type, the measurement (mean() or std()), and the 
#axial direction
split.variable <- strsplit(data.molten$variable, "\\-")

#create a firstElement function
firstElement <- function(x) {x[1]}

#iterate through the list and put the first element into a new column in the dataframe.
data.molten$feature <- sapply(split.variable, firstElement)

#convert this new column to a factor
data.molten$feature <- as.factor(data.molten$feature)

#Subsetp 2
#put the measurement type (mean or std) in it's own varibale
#use split.variable list created in substep 1

#create function to extract second element of each list element
secondElement <- function(x) {x[2]}

#iterate through the list and put the third element into a new column in the dataframe.
data.molten$valueType <- sapply(split.variable, secondElement)

#get rid of the parentheses in this new variable
data.molten$valueType <- sub("\\(\\)$", "", data.molten$valueType)

#rename std as sd
data.molten$valueType <- sub("[s]t[d]", "sd", data.molten$valueType)

#Substep 3
#put axial direction in own column
#use split.variable list created in substep 1

#create function to extract third element of each list element
thirdElement <- function(x) {x[3]}

#iterate through the list and put the third element into a new column in the dataframe.
data.molten$axialDirection <- sapply(split.variable, thirdElement)

#convert this new column to a factor
data.molten$axialDirection <- as.factor(data.molten$axialDirection)
####################################################################
#END Tidying the dataset: Feature Desciptives Transformations
####################################################################

#######################################################################
#BEGIN Tidying the dataset: Dataset Casting
#now that feature, valueType, and axialDirection are their own variables
#the dataset can be cast to put the value under mean or sd, depending
#on the type of measurement.
########################################################################

#Substep 1
#cast (i.e. widen) the data (currently 679,734 observations and 9 variables)
#into a new dataframe.  Resulting dataframe should taken the mean of the values mean
#and standard deviation, aggregated by set, subject, activity, feature, and axial
#direction.   
tidy.data <- dcast(data.molten, subject + set + activity + feature + axialDirection ~ valueType, fun.aggregate = mean )

#Substep 2
#since the mean was taken, give the mean and sd columns meaningful names
names(tidy.data)[6:7] <- c("averageMean", "averageSD")

#######################################################################
#END Tidying the dataset: Dataset Casting
########################################################################

################################################
##END Tidying the dataset
################################################

#BEGIN Garbage Collection
#release objects from memory
rm(data.molten)
rm(data)
rm(split.variable)
#END Garbage Collection

################################################
#BEGIN Write file to directory
################################################
#output to file named 'tidydata.txt'
write.table(tidy.data, file = "./tidydata.txt", sep = "\t", row.names = FALSE )
################################################
#END Write file to directory
################################################
#********************************************************
#END OF SCRIPT
#********************************************************