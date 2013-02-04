# Replace value stored in data frame df's col_name column with new if existing
# value matches any value in old.
# e.g.) data <- replace_value(data, "my_column", c("not found", "unknown"), NA)
replace_value <- function(df, col_name, old, new) {
  df[, col_name] <- ifelse(df[, col_name] %in% old, new, df[, col_name])
  return(df)
}

# Replace factor value stored in data frame df's col_name column if existing
# value is one of old. 'new' will stored.
# e.g.) data <- replace_factor(data, "my_column", c("goood", "gooood"), "good")
replace_factor <- function(df, col_name, old, new) {
  levels(df[, col_name])[levels(df[, col_name]) %in% old] <- new
  return(df)
}

# Merge levels of factors. Oftentimes, training data and validation data may have
# different levels. In such case, merge factor levels.
# e.g.) x <- merge_factor_levels(train, valid, "colName")
#       train <- x[[0]]
#       valid <- x[[1]]
merge_factor_levels <- function(train, valid, col_name) {
  newLevel = unique(c(levels(train[, col_name]), levels(valid[, col_name])))
  train[, col_name] <- factor(train[, col_name], levels=newLevel)
  valid[, col_name] <- factor(valid[, col_name], levels=newLevel)
  return(list(train, valid))
}
