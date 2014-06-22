README.md 
========================================================
README file for the creation of a tidy dataset for the class project
for the Getting and Cleaning Data class as part of the Johns Hopkins Data Science 
specialization on Coursera. 

This repo contains  
* README.md
  * This file, providing a detailed account of the methods and processes in the run_analysis.R script that transformed the raw experimental data into a tidy dataset.  The run_analysis.R script is well commented, and this file describes in detail decisions made in the transformation process.    
* run_analysis.R  
  * R script that tranforms the raw experimental data into a tidy data set as instructed in the class project.  
* CodeBook.md  
  * CodeBook for the dataset produced from the run_analysis.R script.  

## Script Purpose  
The run_analysis.R script takes raw data from the experiment **Human Activity Recognition Using Smartphones Dataset** and creates a summary dataset. 

## Experiment Summary and Reference to Original Experiment and Data
The experiment measured, via estimation, 17 different features of subjects performing various activities.  The features were related to body movements and captured with a smartphone embedded with an accelerometer and gyroscope.  For each subject and activity, repeated measurements were captured for each feature and reported in the raw data.  

For a thorough explanation of the original study  please refer to the following publication and/or this website: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012   

## Data Extraction and Tranformations  
This section walks through the run_analysis.R script and explains how I transformed the raw data into the tidy dataset. 

### Required R Pacakages  
The following packages are required to run the script.   
* plyr  
* reshape2 

### Reading the Raw Files    
The raw data files from the original experiment were loaded into R.  Here are descriptions of each file and the name of the dataframe to which the file was imported.  For each, the number of observations (rows) and variables (columns) is given.

| Raw File Name | DataFrame Name | Description | Dimensions(obs./var.) |  
| :------------ | :------------- | :---------- | :-------------------- |   
| X_test.txt | test.measures | measurements taken from the subjects in the test group | 2947/561 |  
| X_train.txt | train.measures | measurements taken from the subjects in the training group | 7352/561 |  
| y_test.txt | test.activity | type of activity being performed in the test group for each measurement | 2947/1 |  
| y_train.txt | train.activity | type of activity being performed in the training group for each measurement | 7352/1 |  
| subject_test.txt | test.subject | the id of the subject in the test group being measured (1 of 30 pariticpants) | 2947/1 |
| subject_train.txt | train.subject | the id of the subject in the training group being measured (1 of 30 participants) | 7352/1 |   
| features.txt | features | list of the features matching the order in which they were captured in X_test and X_train | 561/2 |  
| activity_labels.txt | activity.type | lookup table listing the type of activities performed by the participants | 6/2 |  

None of the raw files contained column headings.  All files were read using this code framework.  
```
dataframe.name <- read.table(raw.filename, header = FALSE)
```
### Giving Dataframe Variables Meaningful Column Names  
Now that all the raw data is loaded into R, it is worthwhile to give the files meaningful column names, since the raw data did not include column headers. Here are the dataframe column name transformation and explanations.  

#### features dataframe  

The **features** dataframe contains the featureId and feature description, and thus the column names become "featureId"" and "feature".  

```
> features[c(1:3,559:561),]
    featureId              feature
1           1    tBodyAcc-mean()-X
2           2    tBodyAcc-mean()-Y
3           3    tBodyAcc-mean()-Z
559       559 angle(X,gravityMean)
560       560 angle(Y,gravityMean)
561       561 angle(Z,gravityMean) 
```  

#### test.measures and training.measures  
The **test.measures** and **training.measures** dataframes contain all the feature/value paired measurements for one activity for one subject (from the respective test or training group) at one instance in time. (Note that the activity is identified in a different dataframe and will be merged later.)  The order of these measurements is the same order to the feature description column in the features dataframe, so these 561 columns take column names from features$feature, which is the feature description.    
  
```
#first 20 elements of test.measures
> names(test.measures)
  [1] "tBodyAcc-mean()-X"                    "tBodyAcc-mean()-Y"                   
  [3] "tBodyAcc-mean()-Z"                    "tBodyAcc-std()-X"                    
  [5] "tBodyAcc-std()-Y"                     "tBodyAcc-std()-Z"                    
  [7] "tBodyAcc-mad()-X"                     "tBodyAcc-mad()-Y"                    
  [9] "tBodyAcc-mad()-Z"                     "tBodyAcc-max()-X"                    
 [11] "tBodyAcc-max()-Y"                     "tBodyAcc-max()-Z"                    
 [13] "tBodyAcc-min()-X"                     "tBodyAcc-min()-Y"                    
 [15] "tBodyAcc-min()-Z"                     "tBodyAcc-sma()"                      
 [17] "tBodyAcc-energy()-X"                  "tBodyAcc-energy()-Y"                 
 [19] "tBodyAcc-energy()-Z"                  "tBodyAcc-iqr()-X" 
```  

#### test.subject and train.subject  
The **test.subject** and **train.subject** dataframes are simply the numerical identifier of the subject being measured, for their respective sets.  They each take the column name "subject".  
 
```  
> head(test.subject)
  subject
1       2
2       2
3       2
4       2
5       2
6       2
```  

#### test.activity and train.activity  
The **test.activity** and **train.activity** dataframes are the id number of the activity peformed, for all measurements in their respective sets.  This is a foreign key to the **activity.type** dataframe.  It takes the column name "activityId".  

```  
> head(test.activity)
  activityId
1          5
2          5
3          5
4          5
5          5
6          5
```  

#### activity.type  
The **activity.type** dataframe is a lookup table of the six activities.  It takes the column names "activityId" and "activity".  

```  
> activity.type
  activityId           activity
1          1            WALKING
2          2   WALKING_UPSTAIRS
3          3 WALKING_DOWNSTAIRS
4          4            SITTING
5          5           STANDING
6          6             LAYING
```    

### Building a Single Dataset  
The next step is to join the related test set variables together, join the related training set variables together, and then combine the resulting test and training dataframes into a single dataframe.  

During this process I learned that the merge() function has a sort argument.  

```  
merge(x, y, by = intersect(names(x), names(y)),
      by.x = by, by.y = by, all = FALSE, all.x = all, all.y = all,
      sort = TRUE, suffixes = c(".x",".y"),
      incomparables = NULL, ...)
```  

The default is TRUE, in which the result would be sorted by columns.  But even if set to FALSE, the result is still reordered in some way, although I did not determine the pattern.  Regardless, each dataframe needs to retain its order so that the subject, activity, and measures dataframes can be bound together at a later step.

Thus, the join() function was applied from the plyr package, which maintains the original sort order.  Here are the steps taken with each dataframe.  

#### Substep 1 - Join activity descriptor to activity id.  
The **test.activity** dataframe is currently simply the id of the activity.  In order to get the descriptive activity name onto the dataframe, **activity.type** was joined to it, matching by **activityId**.  

Using this code  

```
test.activity <- join(x = test.activity, y = activity.type
                      ,by = "activityId", type = "left" )  
```  
Results in this dataframe.  
```  
> test.activity[c(1:3,559:561),]
    activityId activity
1            5 STANDING
2            5 STANDING
3            5 STANDING
559          1  WALKING
560          1  WALKING
561          1  WALKING
```  

The same process was carried out for the **train.activity** dataframe giving the same result.  

#### Substep 2 - Bind (by column) the subject, activity, and measures dataframes
Build a single dataframe of the test group and single dataframe of the training group by binding the columns of the subject, activity, and measures dataframes together.  In addition, a first column named **set** was added to identify each row as either coming from the test subjects or the training subjects.    

The dataframes were bound column-wise using cbind().  

```  
#bind the dataframes, and also add a column in the first position identifying 
#the group from which the subject/activity/measure data came
test.measures <- cbind(set = "test", test.subject, test.activity, test.measures)
```  

Here is the structure of the first six variables of the resulting **test.measures** dataframe.  

```  
> str(test.measures)
'data.frame':  2947 obs. of  565 variables:
 $ set                                 : Factor w/ 1 level "test": 1 1 1 1 1 1 1 1 1 1 ...
 $ subject                             : int  2 2 2 2 2 2 2 2 2 2 ...
 $ activityId                          : int  5 5 5 5 5 5 5 5 5 5 ...
 $ activity                            : Factor w/ 6 levels "LAYING","SITTING",..: 3 3 3 3 3 3 3 3 3 3 ...
 $ tBodyAcc-mean()-X                   : num  0.257 0.286 0.275 0.27 0.275 ...
 $ tBodyAcc-mean()-Y                   : num  -0.0233 -0.0132 -0.0261 -0.0326 -0.0278 
 ```  
 
The same process was carried out for the **train.measures** dataframe giving the same result.  

#### Substep 3 - Bind (by rows) the test and training dataframes into a single dataframe
Now that **test.measures** and **train.measures** contain the set, subject, activity, and measures, these can be bound into a single dataframe.  This step meets **MILESTONE 1**.  

```  
measures <- rbind(test.measures, train.measures)  
```   
The resulting **measures** dataframe has 10,299 observations and 565 varaibles, which is what is expected.  

| Set | Observation Count |  
| :-- | -------------: |  
| test | 2,947 |  
| train | 7,352 |  
| ----- | ------ |  
| total | 10,299 |  

The 565 variables come from 561 measures, plus the set (1), the activityId (1), the activity description (1), and the subject id (1).  

#### Substep 4 - Garbage Collection  
At the completion of a single dataframe, the subject, activity, and measure dataframes for the test and training sets can be released from memory, as well as the activity lookup table and the features table.  

### Extracting Mean and Standard Deviation Measurements  
The objective is to create a dataframe with 
* set
* subject
* activityId
* activity
* all measurements containing the string "mean()"
* all measurements containing the string "std()"  

The structure of the **measures** dataframe is currently  
* columns 1 through 4 - set, subject, activityId, activity 
* columns 5 through 565 - feature names of measurements  

Thus, the result will keep columns 1 through 4 and any of 5 through 565 where the string "mean()" or "std()" is found.  

#### Substep 1 - Find the variables (columns) that should be kept.  
In this step, create a logical vector containing TRUE for the first four elements (set, subject, activityId, and activity description, all of which should be kept), and TRUE for any column name in measures (columns 5 - 565 ) that contain the string "mean()" 
or "std()".  These are the columns that will be subsetted into a dataframe.  

Using **grepl()** in this fashion  

```  
columns.to.keep <- c(rep(TRUE,4), grepl("std|mean[\\(\\)]", names(measures[5:565])))
```  
The resulting logical dataframe contains 565 elements. 

```  
> length(columns.to.keep)
[1] 565
> columns.to.keep[1:60]
 [1]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE
[16] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
[31] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE
[46]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  
```  

#### Substep 2 - Subset Dataframe  

Using the logical vector, a dataframe meeting **MILESTONE 2** is constructed, taking all observations (rows) of the measures dataframe, but only those columns that have the string "mean()" or "std()", as well as the first four columns.  

```
#subset all rows of measures dataframe for only those columns in which 
#columns.to.keep is TRUE
data <- measures[, c(columns.to.keep)]  
```  

#### Substep 3 - Garbage Collection  
At this point, the measures dataframe can be released from memory.  

### Tidying the Dataset  
Next, steps are taken to build a tidy dataset, which meets **MILESTONES 3, 4, and 5**.
Processes are taken to 
* make sure all variable names are descriptve
* data is resahped for aggregation  

Note that steps have been taken previously in the script to give variables descriptive names, and continues here.  

