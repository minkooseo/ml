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
#
# See merge_factor_levels_for_df for merging factors for two data frames.
replace_factor <- function(df, col_name, old, new) {
  levels(df[, col_name])[levels(df[, col_name]) %in% old] <- new
  return(df)
}

# Merge levels of factors for column 'col_name' in lst[[1]] and lst[[2]].
merge_factor_levels <- function(lst, col_name) {
  stopifnot(length(lst) == 2)
  first <- lst[[1]]
  second <- lst[[2]]
  newLevel = unique(c(levels(first[, col_name]), levels(second[, col_name])))
  first[, col_name] <- factor(first[, col_name], levels=newLevel)
  second[, col_name] <- factor(second[, col_name], levels=newLevel)
  return(list(first, second))
}

# Get the factor column names.
find_factor_columns <- function(df) {
  return(names(df)[
    which(sapply(names(df), 
                 function(colName) { is.factor(df[1, colName]) }))])
}

# Automatically figure out factor columns and merge their levels.
# e.g.) Given train and valid data frame, 
#       x <- merge_factor_levels_for_df(list(train, valid))
#       train <- x[[1]]
#       valid <- x[[2]]
merge_factor_levels_for_df <- function(lst) {
  stopifnot(length(lst) == 2)
  # Get factor column names.
  col_names1 <- find_factor_columns(lst[[1]])
  col_names2 <- find_factor_columns(lst[[2]])
  stopifnot(col_names1 == col_names2)
  for (cn in col_names1) {
    lst <- merge_factor_levels(lst, cn)
  }
  return(lst)
}

# Represent factor with multiple columns, so that the number of levels in 
# each column is small. This is often necessary, for example, in randomForest
# whose max. number of levels is 32.
#
# For this, this function converts factor as numeric, and then re-represents it
# as base max_levels digits. Each digit becomes new columns.
# e.g.) x <- data.frame(v=as.factor(c(1, 2, 3, 4, 5)))
#       x <- split_factor_to_columns(x, 'v', 2)
split_factor <- function(df, col_name, max_levels, 
                         create_as_factor=TRUE, drop_original=FALSE) {
  values <- as.numeric(df[, col_name])
  idx <- 1
  nlevels <- nlevels(df[, col_name])
  while(nlevels > 0) {
    new_values <- values %% max_levels
    if (create_as_factor) {
      df[, paste0(col_name, idx)] <- as.factor(values %% max_levels)
    } else {
      df[, paste0(col_name, idx)] <- values %% max_levels
    }
    values <- values %/% max_levels
    nlevels <- nlevels %/% max_levels
    idx <- idx + 1
  }
  if (drop_original) {
    df <- df[, !(names(df) %in% c(col_name))]
  }
  return(df)
}

# Same with split_factor, but perform it for the vector of column names.
split_multiple_factors <- function(df, col_names, max_levels, 
                                   create_as_factor=TRUE, drop_original=FALSE) {
  for (cn in col_names) {
    df <- split_factor(df, cn, max_levels, create_as_factor, drop_original)
  }
  return(df)
}

# Sort factor level. This is useful when used in combination with split_factor or
# split_multiple_factors. If levels are sorted, it's likely that similarly named
# levels appear closely when new columns are created as numeric, i.e., 
# create_as_factor=FALSE.
sort_factor_levels <- function(df, col_names) {
  for (cn in col_names) {
    df[, cn] <- factor(df[, cn], levels=sort(levels(df[, cn])))
  }
  return(df)
}


# Fill in NA value in data$col_name, with the default_value.
fill_in_na <- function(data, col_name, default_value) {
  data[, col_name] <- ifelse(
    is.na(data[, col_name]),
    default_value,
    data[, col_name])
  return(data)
}