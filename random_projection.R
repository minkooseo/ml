library(Matrix)
random_projection <- function(train, target_dim) {
  R = matrix(nrow = ncol(train), ncol = target_dim)
  set.seed(4585)
  R[,] = rnorm(ncol(train)*target_dim)
  return(data.frame(as.matrix(train %*% R)))
}
