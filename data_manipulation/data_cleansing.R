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
# e.g.) x <- merge_factor_levels(list(train, valid), "colName")
#       x <- merge_factor_levels(list(train, valid), "colName2")
#       train <- x[[0]]
#       valid <- x[[1]]
merge_factor_levels <- function(lst, col_name) {
  first <- lst[[1]]
  second <- lst[[2]]
  newLevel = unique(c(levels(first[, col_name]), levels(second[, col_name])))
  first[, col_name] <- factor(first[, col_name], levels=newLevel)
  second[, col_name] <- factor(second[, col_name], levels=newLevel)
  return(list(first, second))
}