#!/usr/bin/env Rscript
library(e1071)

build_svm <- function(train, should_tune=FALSE, kernel='linear') {
  formula = formula("label ~ .")
  type = 'C-classification'
  print('Kernel:')
  print(kernel)
  if (!should_tune) {
    print("Using default parameter...")
    return(svm(formula,
               data=train,
               type=type,
               kernel=kernel,
               probability=TRUE))
  } else {
    print("Using tuned svm parameter...")
    # tunecontrol=tune.control(cross=10)
    return(tune.svm(formula,
                    data=train,
                    type=type,
                    kernel=kernel,
                    cost=2^(-1:1),
                    gamma=2^(-1:1),
                    probability=TRUE)$best.model)
  }
}
