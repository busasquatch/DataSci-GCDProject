README.md 
========================================================
README file for the creation of a tidy dataset for the class project
for the Getting and Cleaning Data class as part of the Johns Hopkins Data Science 
specialization on Coursera. 

This repo contains  
* README.md
  * This file, providing a detailed account of the methods and processes in the run_analysis.R script that transformed the raw experimental data into a tidy dataset.  The run_analysis.R script is well commented, and this file describes in detail decisions made in the transformation process.    
* run_analysis.R  
  * R script that transforms the raw experimental data into a tidy data set as instructed in the class project.  
* CodeBook.md  
  * Metadata for the dataset produced from the run_analysis.R script.  

## Script Purpose  
The run_analysis.R script takes raw data from the experiment **Human Activity Recognition Using Smartphones Dataset** and creates a summary dataset. The summary is to contain one row (observation) for each distinct subject/set/activity/feature/axialDirection set, along with the average mean and average standard deviation for that set.  For definitions of the data variables, see the CodeBook.

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
| subject_test.txt | test.subject | the id of the subject in the test group being measured (1 of 30 participants) | 2947/1 |
| subject_train.txt | train.subject | the id of the subject in the training group being measured (1 of 30 participants) | 7352/1 |   
| features.txt | features | list of the features matching the order in which they were captured in X_test and X_train | 561/2 |  
| activity_labels.txt | activity.type | lookup table listing the type of activities performed by the participants | 6/2 |  

None of the raw files contained column headings.  All files were read using this code framework.  

```r
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
The **test.activity** and **train.activity** dataframes are the id number of the activity performed, for all measurements in their respective sets.  This is a foreign key to the **activity.type** dataframe.  It takes the column name "activityId".  

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


```r
merge(x, y, by = intersect(names(x), names(y)), by.x = by, by.y = by, all = FALSE, 
    all.x = all, all.y = all, sort = TRUE, suffixes = c(".x", ".y"), incomparables = NULL, 
    ...)
```


The default is TRUE, in which the result would be sorted by columns.  But even if set to FALSE, the result is still reordered in some way, although I did not determine the pattern.  Regardless, each dataframe needs to retain its order so that the subject, activity, and measures dataframes can be bound together at a later step.

Thus, the join() function was applied from the plyr package, which maintains the original sort order.  Here are the steps taken with each dataframe.  

#### Building: Substep 1 - Join activity descriptor to activity id.  
The **test.activity** dataframe is currently simply the id of the activity.  In order to get the descriptive activity name onto the dataframe, **activity.type** was joined to it, matching by **activityId**.  

Using this code  


```r
test.activity <- join(x = test.activity, y = activity.type, by = "activityId", 
    type = "left")
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

#### Building: Substep 2 - Bind (by column) the subject, activity, and measures dataframes
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

#### Building: Substep 3 - Bind (by rows) the test and training dataframes into a single dataframe
Now that **test.measures** and **train.measures** contain the set, subject, activity, and measures, these can be bound into a single dataframe.  This step meets **MILESTONE 1**.  


```r
measures <- rbind(test.measures, train.measures)
```

The resulting **measures** dataframe has 10,299 observations and 565 variables, which is what is expected.  

| Set | Observation Count |  
| :-- | -------------: |  
| test | 2,947 |  
| train | 7,352 |  
| ----- | ------ |  
| total | 10,299 |  

The 565 variables come from 561 measures, plus the set (1), the activityId (1), the activity description (1), and the subject id (1).  

#### Building: Substep 4 - Garbage Collection  
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

#### Extracting: Substep 1 - Find the variables (columns) that should be kept.  
In this step, create a logical vector containing TRUE for the first four elements (set, subject, activityId, and activity description, all of which should be kept), and TRUE for any column name in measures (columns 5 - 565 ) that contain the string "mean()" 
or "std()".  These are the columns that will be subsetted into a dataframe.  

Using **grepl()** in this fashion  

```  
#match on std() or mean()
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

#### Extracting: Substep 2 - Subset Dataframe  

Using the logical vector, a dataframe meeting **MILESTONE 2** is constructed, taking all observations (rows) of the measures dataframe, but only those columns that have the string "mean()" or "std()", as well as the first four columns.  


```r
# subset all rows of measures dataframe for only those columns in which
# columns.to.keep is TRUE
data <- measures[, c(columns.to.keep)]
```

The new dataframe still has 10,299 observations, but now only has 70 variables.  

```    
> names(data)
 [1] "set"                         "subject"                     "activityId"                 
 [4] "activity"                    "tBodyAcc-mean()-X"           "tBodyAcc-mean()-Y"          
 [7] "tBodyAcc-mean()-Z"           "tBodyAcc-std()-X"            "tBodyAcc-std()-Y"           
[10] "tBodyAcc-std()-Z"            "tGravityAcc-mean()-X"        "tGravityAcc-mean()-Y"       
[13] "tGravityAcc-mean()-Z"        "tGravityAcc-std()-X"         "tGravityAcc-std()-Y"        
[16] "tGravityAcc-std()-Z"         "tBodyAccJerk-mean()-X"       "tBodyAccJerk-mean()-Y"      
[19] "tBodyAccJerk-mean()-Z"       "tBodyAccJerk-std()-X"        "tBodyAccJerk-std()-Y"       
[22] "tBodyAccJerk-std()-Z"        "tBodyGyro-mean()-X"          "tBodyGyro-mean()-Y"         
[25] "tBodyGyro-mean()-Z"          "tBodyGyro-std()-X"           "tBodyGyro-std()-Y"          
[28] "tBodyGyro-std()-Z"           "tBodyGyroJerk-mean()-X"      "tBodyGyroJerk-mean()-Y"     
[31] "tBodyGyroJerk-mean()-Z"      "tBodyGyroJerk-std()-X"       "tBodyGyroJerk-std()-Y"      
[34] "tBodyGyroJerk-std()-Z"       "tBodyAccMag-mean()"          "tBodyAccMag-std()"          
[37] "tGravityAccMag-mean()"       "tGravityAccMag-std()"        "tBodyAccJerkMag-mean()"     
[40] "tBodyAccJerkMag-std()"       "tBodyGyroMag-mean()"         "tBodyGyroMag-std()"         
[43] "tBodyGyroJerkMag-mean()"     "tBodyGyroJerkMag-std()"      "fBodyAcc-mean()-X"          
[46] "fBodyAcc-mean()-Y"           "fBodyAcc-mean()-Z"           "fBodyAcc-std()-X"           
[49] "fBodyAcc-std()-Y"            "fBodyAcc-std()-Z"            "fBodyAccJerk-mean()-X"      
[52] "fBodyAccJerk-mean()-Y"       "fBodyAccJerk-mean()-Z"       "fBodyAccJerk-std()-X"       
[55] "fBodyAccJerk-std()-Y"        "fBodyAccJerk-std()-Z"        "fBodyGyro-mean()-X"         
[58] "fBodyGyro-mean()-Y"          "fBodyGyro-mean()-Z"          "fBodyGyro-std()-X"          
[61] "fBodyGyro-std()-Y"           "fBodyGyro-std()-Z"           "fBodyAccMag-mean()"         
[64] "fBodyAccMag-std()"           "fBodyBodyAccJerkMag-mean()"  "fBodyBodyAccJerkMag-std()"  
[67] "fBodyBodyGyroMag-mean()"     "fBodyBodyGyroMag-std()"      "fBodyBodyGyroJerkMag-mean()"
[70] "fBodyBodyGyroJerkMag-std()" 
```  

#### Extracting: Substep 3 - Garbage Collection  
At this point, the measures dataframe can be released from memory.  

### Tidying the Dataset  
Next, steps are taken to build a tidy dataset, which meets **MILESTONES 3, 4, and 5**.
Processes are taken to 
* make sure all variable names are descriptive
* data is reshaped for aggregation  

Note that steps have been taken previously in the script to give variables descriptive names, and continues here.  

#### Tidying: Substep 1 - Melt (lengthen and narrow) the Dataset  
Using the **melt()** function from the reshape2 package, the dataset of 10,299 observations and 70 variables will be transformed in the dataset of 679,734 observations and 6 variables.  This is essentially pivoting the data on set, subject, activityId, activity and creates observations for each measure (becomes column 'value') and feature (become column 'variable').  


```r
data.molten <- melt(data, id = c(names(data)[1:4]), measure.vars = c(names(data)[-c(1:4)]))
```

The structure of the new **data.molten** dataframe.  

```  
> str(data.molten)
'data.frame':  679734 obs. of  6 variables:
 $ set       : Factor w/ 2 levels "test","train": 1 1 1 1 1 1 1 1 1 1 ...
 $ subject   : int  2 2 2 2 2 2 2 2 2 2 ...
 $ activityId: int  5 5 5 5 5 5 5 5 5 5 ...
 $ activity  : Factor w/ 6 levels "LAYING","SITTING",..: 3 3 3 3 3 3 3 3 3 3 ...
 $ variable  : Factor w/ 66 levels "tBodyAcc-mean()-X",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ value     : num  0.257 0.286 0.275 0.27 0.275 ...
```  

#### Tidying: Substep 2 - Feature Desciptives Transformations (data.molten$variable)  

At this point, the feature descriptions are a concatenation of the feature, the measurement type (mean or standard deviation), and the axial Direction (X, Y, Z, or none).  The following sub-steps split the variable and creates three new variables, one each for the feature, the measurement type, and the axial direction.  
  
##### Tidying/Transform: Substep 2.1 - Characterize and split the feature (data.molten$variable)  
First, the data.molten$variable column is cast from a factor to a character class, allowing string manipulation.  
 

```r
# make the variable being split of class character
data.molten$variable <- as.character(data.molten$variable)
```

The data.molten$variable column is then split at each hyphen in the string.  When two hyphens exists, a list element of three elements is created, when one hyphen exists, a list element of two elements is created. 


```r
# split the feature name by hyphen
split.variable <- strsplit(data.molten$variable, "\\-")
```


Sample of the list **split.variable**  

```  
> split.variable[c(1:3,679732:679734)]
[[1]]
[1] "tBodyAcc" "mean()"   "X"       

[[2]]
[1] "tBodyAcc" "mean()"   "X"       

[[3]]
[1] "tBodyAcc" "mean()"   "X"       

[[4]]
[1] "fBodyBodyGyroJerkMag" "std()"               

[[5]]
[1] "fBodyBodyGyroJerkMag" "std()"               

[[6]]
[1] "fBodyBodyGyroJerkMag" "std()" 
```  

##### Tidying/Transform: Substep 2.2 - Create a variable isolating descriptive feature name  
The first element of each vector in the list contains the isolated feature name.  These are put into a new variable.  


```r
# create a firstElement function
firstElement <- function(x) {
    x[1]
}

# iterate through the list and put the first element into a new column in
# the dataframe.
data.molten$feature <- sapply(split.variable, firstElement)

# convert this new column to a factor
data.molten$feature <- as.factor(data.molten$feature)
```


Here are the first six elements of the new data.molten$feature variable.  
```  
> head(data.molten$feature)
[1] tBodyAcc tBodyAcc tBodyAcc tBodyAcc tBodyAcc tBodyAcc
17 Levels: fBodyAcc fBodyAccJerk fBodyAccMag fBodyBodyAccJerkMag ... tGravityAccMag
```  

##### Tidying/Transform: Substep 2.3 - Create a variable isolating the measurement type  
The second element of each vector in the list contains the isolated measurement type (mean or std).  These are put into a new variable, identifying each observation as either a mean or standard deviation. Then, any measurement of std is renamed to the more common 'sd' abbreviation for standard deviation.  


```r
# use split.variable list created previously

# create function to extract second element of each list element
secondElement <- function(x) {
    x[2]
}

# iterate through the list and put the third element into a new column in
# the dataframe.
data.molten$valueType <- sapply(split.variable, secondElement)

# get rid of the parentheses in this new variable
data.molten$valueType <- sub("\\(\\)$", "", data.molten$valueType)

# rename std as sd
data.molten$valueType <- sub("[s]t[d]", "sd", data.molten$valueType)
```

Here is the resulting head and tail of the new variable 'valueType'.
```  
> head(data.molten$valueType)
[1] "mean" "mean" "mean" "mean" "mean" "mean"
> tail(data.molten$valueType)
[1] "sd" "sd" "sd" "sd" "sd" "sd"
```  

##### Tidying/Transform: Substep 2.4 - Create a variable isolating the axial direction  
The third element of each vector in the list contains the axial direction.  Some measurements are not measured by axial direction and thus this third element will be NULL.   These are put into a new variable, identifying each observation as either a X, Y, Z, or NA axial direction. The new variable is named 'axialDirection'.   


```r
# use split.variable list created previously

# create function to extract third element of each list element
thirdElement <- function(x) {
    x[3]
}

# iterate through the list and put the third element into a new column in
# the dataframe.
data.molten$axialDirection <- sapply(split.variable, thirdElement)

# convert this new column to a factor
data.molten$axialDirection <- as.factor(data.molten$axialDirection)
```


Here is the resulting head and tail of the new 'axialDirection' variable. 

```  
> head(data.molten$axialDirection)
[1] X X X X X X
Levels: X Y Z
> tail(data.molten$axialDirection)
[1] <NA> <NA> <NA> <NA> <NA> <NA>
Levels: X Y Z
```  

The resulting dataframe looks like this.     

```    
> head(data.molten)
   set subject activityId activity          variable     value  feature valueType axialDirection
1 test       2          5 STANDING tBodyAcc-mean()-X 0.2571778 tBodyAcc      mean              X
2 test       2          5 STANDING tBodyAcc-mean()-X 0.2860267 tBodyAcc      mean              X
3 test       2          5 STANDING tBodyAcc-mean()-X 0.2754848 tBodyAcc      mean              X
4 test       2          5 STANDING tBodyAcc-mean()-X 0.2702982 tBodyAcc      mean              X
5 test       2          5 STANDING tBodyAcc-mean()-X 0.2748330 tBodyAcc      mean              X
6 test       2          5 STANDING tBodyAcc-mean()-X 0.2792199 tBodyAcc      mean              X
> 
```  

#### Tidying: Substep 3 - Subset and Casting  

Now that the parts of the 'variable' column have been isolated into distinct columns, the variable can be removed and the dataframe can be recast (or widened), so that two new columns are created, one for the mean value and one for the standard deviation value.  

The **dcast** function from the reshape2 package does all of this in one step, as the user can determine which variables to keep.  To meet the specifications of the project, the **mean of mean values** and the **mean of standard deviation values** will be calculated, grouped by set, subject, activity, feature, and axial direction. 

 

```r
# cast (i.e. widen) the data (currently 679,734 observations and 9
# variables) into a new dataframe.  Resulting dataframe should taken the
# mean of the values mean and standard deviation, aggregated by set,
# subject, activity, feature, and axial direction.
tidy.data <- dcast(data.molten, subject + set + activity + feature + axialDirection ~ 
    valueType, fun.aggregate = mean)
```


Since the mean of mean and mean of standard deviation were taken, these new variables will be given new column names.  


```r
names(tidy.data)[6:7] <- c("averageMean", "averageSD")
```


These steps just completed cast the molten dataset of 679,734 observations and 9 variables into a cast dataset of 5,940 observations and 7 variables.  

Here is a sample and the structure of the resulting **tidy.data** dataset.    
```  
> head(tidy.data)
  subject   set activity      feature axialDirection averageMean  averageSD
1       1 train   LAYING     fBodyAcc              X  -0.9390991 -0.9244374
2       1 train   LAYING     fBodyAcc              Y  -0.8670652 -0.8336256
3       1 train   LAYING     fBodyAcc              Z  -0.8826669 -0.8128916
4       1 train   LAYING fBodyAccJerk              X  -0.9570739 -0.9641607
5       1 train   LAYING fBodyAccJerk              Y  -0.9224626 -0.9322179
6       1 train   LAYING fBodyAccJerk              Z  -0.9480609 -0.9605870
> str(tidy.data)
'data.frame':  5940 obs. of  7 variables:
 $ subject       : int  1 1 1 1 1 1 1 1 1 1 ...
 $ set           : Factor w/ 2 levels "test","train": 2 2 2 2 2 2 2 2 2 2 ...
 $ activity      : Factor w/ 6 levels "LAYING","SITTING",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ feature       : Factor w/ 17 levels "fBodyAcc","fBodyAccJerk",..: 1 1 1 2 2 2 3 4 5 6 ...
 $ axialDirection: Factor w/ 3 levels "X","Y","Z": 1 2 3 1 2 3 NA NA NA NA ...
 $ averageMean   : num  -0.939 -0.867 -0.883 -0.957 -0.922 ...
 $ averageSD     : num  -0.924 -0.834 -0.813 -0.964 -0.932 ...  
```  

At this point, there is one row (observation) for each distinct subject/set/activity/feature/axialDirection set, along with the average mean and average standard deviation for that set.  

#### Tidying: Substep 4 - Garbage Collection
At the completion of tidying of the dataframe, the 'data' dataframe and the 'data.molten' dataframe along with the list 'split.variable' can be released from memory.  

### File Output - Writing to Active Directory  
As a final step, the new 'tidy.data' dataframe is written to a tab-delimited file.  

```r
# output to file named 'tidydata.txt'
write.table(tidy.data, file = "./tidydata.txt", sep = "\t", row.names = FALSE)
```

## End of README.md  



