get_train_and_validation <- function(data, train_ratio) {
  train_idx <- sample(nrow(data), nrow(data) * train_ratio)
  return (list(train=data[train_idx, ],
               validation=data[-train_idx, ]))
}


