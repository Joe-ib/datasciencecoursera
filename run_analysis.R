# GET DATA
usedlibs <- c("data.table","reshape2")
sapply(usedlibs,require,character.only=TRUE,quietly=TRUE)
pathing <-getwd()
LINK <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(LINK,file.path(pathing,"dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

#LABELs & MEASURES
ACTIVITY <- fread(file.path(pathing,"UCI HAR Dataset/activity_labels.txt"),col.names = c("classLabels", "activityName"))
FEATURES <- fread(file.path(pathing,"UCI HAR Dataset/activity_labels.txt"),col.names = c("index", "featureNames"))

TARGET <- grep("(mean|std)\\(\\)",FEATURES[, featureNames])
MEASURE <- FEATURES[TARGET , featureNames]
MEASURE <- gsub('[()]','',MEASURE)

#TRaIN --- DATASET
TRAIN <- fread(file.path(pathing, "UCI HAR Dataset/train/X_train.txt"))[, TARGET, with = FALSE]
data.table::setnames(TRAIN, colnames(TRAIN),MEASURE)
TRAIN_Activity <- fread(file.path(pathing, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
TRAIN_Subjects <- fread(file.path(pathing, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
TRAIN <- cbind(TRAIN_Subjects, TRAIN_Activity, TRAIN)

# LOAD --- DATASET

TEST <- fread(file.path(pathing, "UCI HAR Dataset/test/X_test.txt"))[, TARGET, with = FALSE]
data.table::setnames(TEST, colnames(TEST), MEASURE)
TEST_Activity <- fread(file.path(pathing, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
TEST_Subjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
TEST <- cbind(TEST_Subjects, TEST_Activity, TEST)

# MERGE

COMP <- rbind(TRAIN,TEST)


# TRIM DATA

COMP[["Activity"]] <- factor(COMP[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

COMP[["SubjectNum"]] <- as.factor(COMP[, SubjectNum])
COMP <- reshape2::melt(data = COMP, id = c("SubjectNum", "Activity"))
COMP <- reshape2::dcast(data = COMP, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = COMP, file = "tidyData.txt", quote = FALSE)






