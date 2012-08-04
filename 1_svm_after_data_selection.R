#!/usr/bin/env Rscript
library(e1071)
source('select_rows.R')
source('svm.R')
source('split_tranin_and_validation.R')

print('Loading data...')
load("projected_data.RData")

train$label <- factor(labels)
train.partitioned <- get_train_and_validation(train, 0.7)
print('Getting some data for each label...')
train_subset <- get_first_some_for_each_label(train.partitioned$train)

print('Building SVM...')
svm.params <- tune_svm(train_subset)
svm.model <- build_svm(train_subset, svm.params)
save(svm.model,
     train.partitioned,
     file='svm_first_100_for_each_label.RData')

print('Predicting for validation data...')
# 101th column is label
predicted.validation.label <- predict(svm.model,
                                      train.partitioned$validation[, -101])
print('Accuracy:')
classAgreement(table(predicted.validation.label,
                     train.partitioned$validation$label))$diag
