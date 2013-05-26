library(plyr)
library(reshape2)

# Build slope one model.
#
# Params:
# ratings: A data frame containing (user_id, business_id, stars).
# ...: Options for ddply.
#
# Returns:
# A data frame of (item_id1, item_id2, b) where b represents the average rating
# difference between item 1 and item 2.
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
  ddply(score_diff_per_user, 
        .(item_id1, item_id2), 
        summarize,
        b=mean(diff), ...)
}

library(doMC)
registerDoMC(cores=2)
model.slopeone <- build_slopeone(
  head(rename(data.rating, c("business_id" = "item_id", 
                             "stars" = "rating")), n=1000),
  .parallel=FALSE, 
  .progress="text")