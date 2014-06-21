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

### Script Purpose  
The run_analysis.R script takes raw data from the experiment **Human Activity Recognition Using Smartphones Dataset** and creates a summary dataset. 

### Experiment Summary and Reference to Original Experiment and Data
The experiment measured, via estimation, 17 different features of subjects performing various activities.  The features were related to body movements and captured with a smartphone embedded with an accelerometer and gyroscope.  For each subject and activity, repeated measurements were captured for each feature and reported in the raw data.  

For a thorough explanation of the original study  please refer to the following publication and/or this website: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012   

### Data Extraction and Tranformations  
This section walks through the run_analysis.R script and explains how I transformed the raw data into the tidy dataset. 

#### Required R Pacakages  
The following packages are required to run the script.   
* plyr  
* reshape2 

#### Reading the Raw Files    
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
#### Giving Dataframe Variables Meaningful Column Names  
Now that all the raw data is loaded into R, it is worthwhile to give the files meaningful column names, since the raw data did not include column headers. Here are the dataframe column name transformation and explanations.  

1. The **features** dataframe contains the featureId and feature description, and thus the column names become "featureId"" and "feature".  
2. The **test.measures** dataframe contains all the feature/value paired measurements for one activity for one subject (from the test group) at one instance in time. (Note that the activity is identified in a different dataframe and will be merged later.)  The order of these measurements is the same order to the feature description column in the features dataframe, so these 561 columns take column names from features$feature, which is the feature description.  
3. The **train.measures** dataframe is the same as **test.measures**, except that it is for the training group set.  
4. The **test.subject** dataframe is simply the numerical identifier of the subject being measured, for the test group set.  It takes the column name "subject".  
5. The **train.subject** dataframe is the same as **test.subject**, expect that it is for the training group set.  
6. The **test.activity** dataframe is the id number of the activity peformed, for all measurements in the test group set.  This is a foreign key to the **activity.type** dataframe.  It takes the column name "activityId".  
7. The **train.activity** dataframe is the same as **test.activity**, expect that it is for the training group set.  
8. The **actiity.type** dataframe is a lookup table of the six activities.  It takes the column names "activityId" and "activity".  




### Dataset Dimensions
The dataset **tidydata.txt** contains 5940 rows (observations) and 7 columns (variables).
