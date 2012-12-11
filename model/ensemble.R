#' setup
#+ message=FALSE

library(e1071)
library(nnet)
library(randomForest)
library(rpart)

#' Evaluation Tool
loocv <- function(modeller, 
                  form,
                  predictor,
                  evaluator,
                  data, ...) {
  evals <- foreach(i=1:NROW(data)) %dopar% {
    current.validation <- data[i, ]
    current.train <- data[-i, ]
    evaluator(predictor(modeller(form, data), current.validation),
              current.validation$survived)
  }
  m <- matrix(unlist(evals), ncol=2, byrow=T)
  num_correct <- sum(m[ , 1])
  num_data <- sum(m[ , 2])
  sprintf("Accuracy: %.2f (%d / %d)", num_correct / num_data, num_correct, num_data)
  return(list(accuracy = num_correct / num_data,
              num_correct = num_correct, 
              num_data = num_data, 
              model=modeller(form, data)))
}

evaluator <- function(predicted, answer) {
  answer <- as.numeric(answer) - 1
  list(num_correct = sum(predicted == answer), num_data = NROW(answer))
}


#' Decision tree
rpart.modeller <- function(form, data) {
  rpart(form, data=data)
}

rpart.predictor <- function(model, newdata) {
  return(as.numeric(predict(model, newdata=newdata, type="class")) - 1)
}

#' GLM
glm.modeller <- function(form, data) {
  glm(form, family="binomial", data=data)
}

glm.predictor <- function(model, newdata) {
  return(round(predict(model, newdata=newdata, type="response")))
}

#' Neural net
nnet.modeller <- function(form, data) {
  # !!! Try centering and scaling data !!!!
  # !!! Try more than three layers !!!
  nnet(form, data=data, size = 3)
}

nnet.predictor <- function(model, newdata) {
  as.vector(round(predict(model, newdata=newdata)))
}

#' SVM
svm.modeller <- function(form, data) {
  svm(form, data=data)
}

svm.predictor <- function(model, newdata) {
  as.numeric(predict(model, newdata)) - 1
}


#'Ensemble
ensemble.modeller <- function(form, data) {
  #' Collects predictions from several classifiers.
  model = list(rpart.model = rpart.modeller(form, data), 
               glm.model = glm.modeller(form, data), 
               nnet.model = nnet.modeller(form, data),
               svm.model = svm.modeller(form, data))
  
  predicted <- list(rpart.predicted = rpart.predictor(model$rpart.model, data),
                    glm.predicted = glm.predictor(model$glm.model, data),
                    nnet.predicted = nnet.predictor(model$nnet.model, data),
                    svm.predicted = svm.predictor(model$svm.model, data))
  
  ensemble.data <- as.data.frame(do.call(cbind, predicted))
  ensemble.data$survived <- data$survived
  
  #' Make final prediction combining the results from classifiers.
  model$all.rfModel <- randomForest(survived ~., data=ensemble.data)
  model$all.nnetModel <- nnet(survived ~., data=ensemble.data, size=3)
  return(model)
}

ensemble.basePredictor <- function(model, newdata) {
  predicted <- list(rpart.predicted = rpart.predictor(model$rpart.model, newdata),
                    glm.predicted = glm.predictor(model$glm.model, newdata),
                    nnet.predicted = nnet.predictor(model$nnet.model, newdata),
                    svm.predicted = svm.predictor(model$svm.model, newdata)
  )
  return(predicted)
}

ensemble.rfPredictor <- function(model, newdata) {
  predicted <- ensemble.basePredictor(model, newdata)
  return(as.numeric(
    predict(model$all.rfModel, newdata=as.data.frame(do.call(cbind, predicted)))) - 1)
}

ensemble.nnetPredictor <- function(model, newdata) {
  predicted <- ensemble.basePredictor(model, newdata)
  return(round(
    predict(model$all.nnetModel, newdata=as.data.frame(do.call(cbind, predicted)))))
}

ensemble.meanPredictor <- function(model, newdata) {
  predicted <- ensemble.basePredictor(model, newdata)
  return(round(rowMeans(do.call(cbind, predicted))))
}