#!/usr/bin/env Rscript
library(reshape)
library(randomForest)

train.melt <- data.frame(read.csv('train_data_melt_filtered.csv'))
colnames(train.melt) <- c('id', 'variable', 'value')

# Convert data s.t. it works with randomForest.
train <- cast(... ~ variable, data=train.melt)

# If the above does not work, perform random permutation on the filtered data, or 
# Apply more strict filtering on features.

train_raw  <- EMC_ReadData("train_data.csv")
test_raw  <- EMC_ReadData("test_data.csv")
labels = as.vector(t(read.csv("train_labels.csv", header= FALSE)))

rf <- randomForest(labels ~ ., data=train_raw, importance=TRUE)


save(train.matrix, test, labels, file="projected_data.RData")
