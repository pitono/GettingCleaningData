library(reshape2)

##
## 1. Merges the training and the test sets to create one data set.

## Read and merge subject data
subject_train_data <- read.table("train/subject_train.txt", header=F, col.names=c("SubjectID"))
subject_test_data <- read.table("test/subject_test.txt", header=F, col.names=c("SubjectID"))

## Read and merge Y data
Y_train_data <- read.table("train/y_train.txt", header=F, col.names=c("ActivityID"))
Y_test_data <- read.table("test/y_test.txt", header=F, col.names=c("ActivityID"))


## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## Read features
features <- read.table("features.txt", header=F, as.is=T, col.names=c("MeasureID", "MeasureName"))
X_data_column <- grep(".*mean\\(\\)|.*std\\(\\)", features$MeasureName)
## Read and merge X data
X_train_data <- read.table("train/X_train.txt", header=F, col.names=features$MeasureName)
X_train_data <- X_train_data[,X_data_column]
X_test_data <- read.table("test/X_test.txt", header=F, col.names=features$MeasureName)
X_test_data <- X_test_data[,X_data_column]

X_train_data$ActivityID <- Y_train_data$ActivityID
X_train_data$SubjectID <- subject_train_data$SubjectID
X_test_data$ActivityID <- Y_test_data$ActivityID
X_test_data$SubjectID <- subject_test_data$SubjectID

all_data <- rbind(X_test_data, X_train_data)
col_names <- colnames(all_data)
col_names <- gsub("\\.+mean\\.+", col_names, replacement="Mean")
col_names <- gsub("\\.+std\\.+", col_names, replacement="Std")
colnames(all_data) <- col_names

## 4. Appropriately labels the data set with descriptive activity names. 
activity_labels <- read.table("activity_labels.txt", header=F, as.is=T, col.names=c("ActivityID","ActivityName"))
activity_labels$ActivityName <- as.factor(activity_labels$ActivityName)
merged_labeled_data <- merge(all_data, activity_labels)
write.table(merged_labeled_data,"merged_labeled_data.txt")


## 
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
##
cn = c("ActivityID", "ActivityName", "SubjectID")
measure_vars = setdiff(colnames(merged_labeled_data), cn)
melted_data <- melt(merged_labeled_data, id=cn, measure.vars=measure_vars)
write.table(dcast(melted_data, ActivityName + SubjectID ~ variable, mean), "tidy_data.txt")
