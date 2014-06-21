# CodeBook
## tidydata dataset

This Code Book serves as a data dictionary for the **tidydata.txt** dataset.  Information on data transformations from the original dataset can be found in the README.md file.  

This dataset is a summary of the **Human Activity Recognition Using Smartphones Dataset**.  For a thorough explanation of the original study  please refer to the following publication and this website: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012   

### Dataset Structure  
The file is tab-delmited. 
### Dataset Dimensions
The dataset **tidydata.txt** contains 5940 rows (observations) and 6 columns (variables).   

### Dataset Variables
**subject**  
Description: The id number of the subject  
Type: numeric, integer    
Values (30)  
* 1 through 30  

**activity**  
Description: The activity being performed  
Type: string  
Values (6)  
* WALKING  
* WALKING_UPSTAIRS  
* WALKING_DOWNSTAIRS  
* SITTING  
* STANDING  
* LAYING  

**feature**  
Description: The feature that was measured.  A prefix of **t** denotes a time domain signal and a prefix of **f** denotes a frequence domain signal.    
Type : string  
Values (17)  
* fBodyAcc  
* fBodyAccJerk  
* fBodyAccMag  
* fBodyBodyAccJerkMag  
* fBodyBodyGyroJerkMag  
* fBodyBodyGyroMag  
* fBodyGyro  
* tBodyAcc  
* tBodyAccJerk  
* tBodyAccJerkMag  
* tBodyAccMag  
* tBodyGyro  
* tBodyGyroJerk  
* tBodyGyroJerkMag  
* tBodyGyroMag  
* tGravityAcc  
* tGravityAccMag  

**axialDirection**
Description: Some features are measured in 3-axial signals.  The variable identifies either the X, Y, or Z axial direction.  If the feature is not measured in an axial direction, the value is NA.  
Type: string  
Values (3) plus NA  
* X  
* Y  
* Z  

**averageMean**  
Description: The average of all mean measurements, grouped by subject, activity, feature, and axialDirection.  
Type: numeric, continuous  
Values: many  

**averageSD**  
Description: The average of all standard deviation measurements, grouped by subject, activity, feature, and axialDirection.  
Type: numeric, continuous  
Values: many  

**End of data variables**  

# End of CodeBook

