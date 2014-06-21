README.md 
========================================================
README file for the creation of a tidy dataset for the class project
for the Getting and Cleaning Data class as part of the Johns Hopkins Data Science 
specialization on Coursera. 

This repo contains  
* README.md
  * This file, providing a detailed account of the methods and processes in the run_analysis.R script that transformed the raw experimental data into a tidy dataset.  
* run_analysis.R  
  * R script that tranforms the raw experimental data into a tidy data set as instructed in the class project.  
* CodeBook.md  
  * CodeBook for the dataset produced from the run_analysis.R script.  

### Reference to Original Experiment and Data
Th run_analysis.R script takes raw data from the experiment **Human Activity Recognition Using Smartphones Dataset** and creates a summary dataet.  For a thorough explanation of the original study  please refer to the following publication and/or this website: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012   

### Dataset Structure  
The file is tab-delmited. 
The file is an aggregation of the average mean and average standard deviation, aggregated by the activity, feature, and axial direction for each of the 30 subjects participating in the experiment. Subjects were assigned to either a train(ing) or test dataset.  

### Dataset Dimensions
The dataset **tidydata.txt** contains 5940 rows (observations) and 7 columns (variables).
