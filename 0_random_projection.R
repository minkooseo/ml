#!/usr/bin/env Rscript
library(Matrix)
source("EMC_IO.r")

train.csr  <- EMC_ReadData("train_data.csv")
test.csr  <- EMC_ReadData("test_data.csv")
labels = as.vector(t(read.csv("train_labels.csv", header= FALSE)))

P = matrix(nrow = 592158, ncol = 100)
set.seed(4585)
P[,] = rnorm(592158*100)

ProjectedTrain = train.csr %*% P
ProjectedTest = test.csr %*% P
train = data.frame(as.matrix(ProjectedTrain))
test = data.frame(as.matrix(ProjectedTest))

save(file="projected_data.RData")
