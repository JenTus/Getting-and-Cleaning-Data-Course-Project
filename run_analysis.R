library(dplyr)
setwd("cleandata/UCI HAR Dataset")
download.file(url = "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = "couseworkdataset.zip",
              method = "curl")
#labels and features
activity_lables <- read.table("activity_labels.txt")
features <- read.table("features.txt")

#extract std&dev
features_want <- grep("mean|std",features[,2])
features_want.names <- features[features_want,2]
features_want.names <- gsub("[-()]","",features_want.names)

#train
X_train <- read.table("train/X_train.txt")
Y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")

#cbind train
train <- X_train[features_want]
train <- cbind(Y_train, subject_train, train)

#test
X_test <- read.table("test/X_test.txt")
Y_test <- read.table("test/y_test.txt")
subject_test <- read.table("test/subject_test.txt")

#cbind test
test<- X_test[features_want]
test <- cbind(Y_test, subject_test, test)

#merge train&test and add lables
all <- rbind(train, test)
colnames(all) <- c("activity", "subject", features_want.names)

all$activity <- factor(all$activity)
all$subject <- factor(all$subject)
all.melted <- melt(all, id = c("activity", "subject"))
all.mean <- cast(all.melted, subject + activity ~ variable, mean)

#mean data
groupData <- all %>%
    group_by(subject, activity) %>%
    summarise_each(funs(mean))

write.table(groupData, "MeanData.txt", row.names = FALSE)
