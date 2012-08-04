#!/usr/bin/env Rscript
library(caret)
library(e1071)
library(doMC)
source('svm.R')
source('select_rows.R')

registerDoMC(cores=4)

print('Loading data...')
load('a2_permuted.RData')

# Convert label 1, 2, 3, ... to L1, L2, L3, ...
labels <- unlist(lapply(as.list(labels), function(x) { paste('C', x, sep='') })) 
train$label <- factor(labels)
train.sampled <- get_partial_data(train, 100)

build_model <- function(partial_data) {
  partial_data$label <- factor(partial_data$label)  # Partial fata may not have all labels.
  return(train(label ~ ., data=partial_data, method="svmLinear", tuneLength=3,
               trControl=trainControl(number=1), scaled=TRUE))
}

should_estimate_speed = TRUE

if (should_estimate_speed) {
  print("Estimate training speed...")

  # Estimate training speed.
  results <- foreach(i=seq(5, 20, 5)) %do% {
    print(i)
    start <- proc.time()
    build_model(get_partial_data(train, i))
    end <- proc.time()
    return(list(size=i*nlevels(train$label), time=(end - start)[3]))
  }
  
  time_taken <- as.data.frame(matrix(unlist(results), ncol=2, byrow=T))
  colnames(time_taken) <- c("size", "time")
  print("Estimatied training speed:")
  print(time_taken)

  print("Expected training time:")
  predict(lm(time ~ poly(size, 4), data=time_taken),
          data.frame(size=nrow(train.sampled)))
}

print('Building Model...')
model <- build_model(train.sampled)
print(model)

save(model, file='a3_model.RData')

print('Predicting for validation data...')
predicted.label <- predict(model, train)

print('Accuracy:')
classAgreement(table(predicted.label, train$label))
