#!/usr/bin/env Rscript
library(e1071)

load('projected_data.RData')
load('svm_first_100_for_each_label.RData')
print('Predicting for test data...')
predicted.test.raw <- predict(svm.model, test, probability=TRUE)
predicted.test.prob <- attr(predicted.test.raw, 'probabilities')
output = data.frame(id=1:nrow(predicted.test.prob))
output = cbind(output, predicted.test.prob)
colnames(output) = c("id", paste("class",0:(ncol(predicted.test.prob)-1),sep=""))
write.csv(output, "svm_first_100_for_each_label_submit.csv", row.names=FALSE)
