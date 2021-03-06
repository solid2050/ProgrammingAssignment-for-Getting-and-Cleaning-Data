library(readr)
library(dplyr)
library(magrittr)
library(data.table)
library(stringr)
library(reshape2)

# Merges the training and the test sets to create one data set.
## Creating a test dataset by merging three datasets from the folder "test"
subject_test <- read.table(paste("./getdata_projectfiles_UCI HAR Dataset/",
                                 "UCI HAR Dataset/test/subject_test.txt", sep = ""), 
                           quote="\"", comment.char="", stringsAsFactors=FALSE)
X_test <- read.table(paste("./getdata_projectfiles_UCI HAR Dataset/",
                           "UCI HAR Dataset/test/X_test.txt", sep = ""), 
                     quote="\"", comment.char="", stringsAsFactors=FALSE)
Y_test <- read.table(paste("./getdata_projectfiles_UCI HAR Dataset/",
                           "UCI HAR Dataset/test/y_test.txt", sep = ""), 
                     quote="\"", comment.char="", stringsAsFactors=FALSE)

## Creating a training dataset by merging three datasets from the folder "train"
subject_train <- read.table(paste("./getdata_projectfiles_UCI HAR Dataset/",
                                  "UCI HAR Dataset/train/subject_train.txt", sep = ""), 
                            quote="\"", comment.char="", stringsAsFactors=FALSE)
X_train <- read.table(paste("./getdata_projectfiles_UCI HAR Dataset/",
                            "UCI HAR Dataset/train/X_train.txt", sep = ""), 
                      quote="\"", comment.char="", stringsAsFactors=FALSE)
Y_train <- read.table(paste("./getdata_projectfiles_UCI HAR Dataset/",
                            "UCI HAR Dataset/train/y_train.txt", sep = ""), 
                      quote="\"", comment.char="", stringsAsFactors=FALSE)


## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
features <- read.table(paste("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/",
                             "features.txt", sep=""), quote="\"", comment.char="")

colnames(X_test) = features$V2
colnames(X_train) = features$V2
Test = do.call(cbind, list(subject_test, Y_test, X_test)) 
Train = do.call(cbind, list(subject_train, Y_train, X_train)) 
Activities = rbind(Test, Train)
Activities[, c(1,2,grep("[Mm]ean|[Ss]td", names(Activities)))] -> subset_activities

# 4. Appropriately labels the data set with descriptive variable names.

subset_activities %>% rename(Subject_id = V1, Activity = V1.1) -> subset_activities
gsub("Acc", "Accelerometer", names(subset_activities))-> names(subset_activities)
gsub("Gyro", "Gyroscope", names(subset_activities)) -> names(subset_activities)
gsub("Mag", "Magnitude", names(subset_activities)) -> names(subset_activities)
gsub("^t", "Time", names(subset_activities)) -> names(subset_activities)
gsub("^f", "Frequency", names(subset_activities)) -> names(subset_activities)
gsub("tBody", "TimeBody", names(subset_activities)) -> names(subset_activities)

# 3. Uses descriptive activity names to name the activities in the data set
subset_activities$Activity = factor(subset_activities$Activity, 
                                    labels = c("WALKING", "WALKING_UPSTAIRS",
                                               "WALKING_DOWNSTAIRS", "SITTING",
                                               "STANDING", "LAYING")) 

table(subset_activities$Activity)

# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

melt(subset_activities, c("Activity", "Subject_id"), variable.name = "Measure_Axis",
     value.name = "Value") -> tidy_data

tidy_data %>% group_by(Activity, Subject_id, Measure_Axis) %>% 
        summarize(average = mean(Value)) -> tidy_data

## Alternative way of finding averages
subset_activities %>% group_by(Activity, Subject_id) %>% 
        summarize_all(funs(mean)) -> tidy_data2

write.table(tidy_data, "Tidy_data.txt", row.names = F)
write.table(tidy_data2, "Tidy_data2.txt", row.names = F)


#### saving datasets in Rdata format to use in the markdown codebook
save(subject_test, file = "subject_test.Rdata")
save(subject_train, file = "subject_train.Rdata")
save(X_test, file = "X_test.Rdata")
save(X_train, file = "X_train.Rdata")
save(Y_test, file = "Y_test.Rdata")
save(Y_train, file = "Y_train.Rdata")
save(features, file = "features.Rdata")
save(Activities, file = "Activities.Rdata")
save(subset_activities, file = "subset_activities.Rdata")
save(tidy_data, file = "tidy_data.Rdata")