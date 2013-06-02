require(data.table)
require(plyr)
require(reshape2)

# Build slope one model.
#
# Params:
# ratings: A data frame containing (user_id, item_id, stars).
# ...: Options for ddply.
#
# Returns:
# A data table of (item_id1, item_id2, b) where b represents the average rating
# difference of 'item 2 rating' - 'item 1 rating'.
build_slopeone <- function(ratings, ...) {
  if (NROW(ratings) == 0) {
    return(data.table(data.frame(item_id1=c(), item_id2=c(), b=c(), support=c())))
  }
  ratings <- ratings[, c('user_id', 'item_id', 'rating')]
  # Generates all pairs of (item id 1, item id 2, diff) if both of item 1 and
  # 2 is rated by the same user.
  score_diff_per_user <- ddply(ratings, .(user_id), function(rows) {
    if (NROW(rows) > 1) {
      # A user may have rated an item multiple times. In such case, get average ratings 
      # for such items.
      rows <- unique(ddply(rows, .(item_id), transform, rating=mean(rating)))  
      # Compute diff of every pair of items.
      pair_rows_nums <- subset(
          expand.grid(rows_num1=1:NROW(rows), rows_num2=1:NROW(rows)),
          rows_num1 != rows_num2)
      data.frame(
          item_id1=rows[pair_rows_nums$rows_num1, 'item_id'],
          item_id2=rows[pair_rows_nums$rows_num2, 'item_id'],
          diff=rows[pair_rows_nums$rows_num2, 'rating'] 
              - rows[pair_rows_nums$rows_num1, 'rating'])
    }
  }, ...)
  # Compute average score diff between item 1 and item 2.
  model <- data.table(
      ddply(score_diff_per_user, 
            .(item_id1, item_id2), 
            summarize,
            b=mean(diff), support=NROW(diff)))
  setkey(model, item_id1, item_id2)
  return(model)
}

# Predict score for target_item_id given ratings of (item_id, rating).
#
# Params:
# model: A data table produced by build_slopeone. This contains
#   (item id 1, item id 2, b).
# target_item_id: Target item id to predict rating.
# ratings: A data table containing (item id, rating) of the user.
#
# Returns:
# Predicted rating score.
predict_slopeone <- function(model, target_item_id, ratings) {
  # If target_id is already rated by the user, return that rating.
  already_rated <- subset(ratings, ratings$item_id == target_item_id)
  if (NROW(already_rated) == 1) {
    return(already_rated$rating)
  } else if (NROW(already_rated) > 1) {
    stop(paste(target_item_id, " is already rated by user, but there are multiple ratings."))
  }

  # Compute average ratings.
  ratings <- rename(ratings, c('item_id'= "item_id1"))
  ratings <- cbind(ratings, item_id2=target_item_id)
  setkey(ratings, item_id1, item_id2)
  return(mean(model[ratings, b+rating]$V1, na.rm=TRUE))
}

demo <- function() {
  model <- build_slopeone(data.frame(
    user_id=c('u1', 'u1', 'u1', 'u2', 'u2'),
    item_id=c('i1', 'i2', 'i3', 'i1', 'i4'),
    rating=c(3, 4, 5, 2, 4)))
  
  predict_slopeone(model,
    'i2', data.table(data.frame(item_id=c('i1', 'i4'), rating=c(4, 4))))
}