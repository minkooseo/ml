library(data.table)
library(plyr)
library(reshape2)

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
  ratings <- ratings[, c('user_id', 'item_id', 'rating')]
  # Generates all pairs of (item id 1, item id 2, diff) if both of item 1 and
  # 2 is rated by the same user.
  score_diff_per_user <- ddply(ratings, .(user_id), function(rows) {
    if (NROW(rows) > 2) {
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
  item_id_pair_and_b <- data.table(
      ddply(score_diff_per_user, 
            .(item_id1, item_id2), 
            summarize,
            b=mean(diff), support=NROW(diff)))
  setkey(item_id_pair_and_b, item_id1, item_id2)
  return(item_id_pair_and_b)
}

# Predict score for target_item_id given ratings of (item_id, rating).
#
# Params:
# item_id_pair_and_b: A data table produced by build_slopeone. This contains
#   (item id 1, item id 2, b).
# target_item_id: Target item id to predict rating.
# ratings: A data table containing (item id, rating) of the user.
#
# Returns:
# Predicted rating score.

predict_slopeone <- function(item_id_pair_and_b, target_item_id, ratings) {
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
  browser()
  return(item_id_pair_and_b[ratings, mean(rating + b)])
}

model <- data.table(data.frame(
  item_id1=c('A', 'B', 'C'),
  item_id2=c('a', 'b', 'c'),
  diff=c(1, 2, 3),
  stringsAsFactors=FALSE))
setkey(model, item_id1, item_id2)

predict_slopeone(model,
  'b', data.frame(item_id=c('B', 'C'), rating=c(1, 2)))
