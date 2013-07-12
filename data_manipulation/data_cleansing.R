require(foreach)
require(stringr)

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
split_factor_by_base32 <- function(
  df, col_name, max_levels, drop_original=FALSE) {
  values <- as.numeric(df[, col_name])
  idx <- 1
  nlevels <- nlevels(df[, col_name])
  while(nlevels > 0) {
    new_values <- values %% max_levels
    df[, paste0(col_name, idx)] <- as.factor(values %% max_levels)
    values <- values %/% max_levels
    nlevels <- nlevels %/% max_levels
    idx <- idx + 1
  }
  if (drop_original) {
    df <- df[, !(names(df) %in% c(col_name))]
  }
  return(df)
}

# Sort factor level. This is useful preprocessing for split_factor or
# split_multiple_factors. If levels are sorted, it's likely that similarly named
# levels may mean something very similar. Therefore, sorting factor level will result
# in similar value in splitted columns added by split_factor or split_multiple_factors.
sort_factor_levels <- function(df, col_names) {
  for (cn in col_names) {
    df[, cn] <- factor(df[, cn], levels=sort(levels(df[, cn])))
  }
  return(df)
}

# Remove levels from factor 'data' if occurrences of the levels are not within top n.
# Decision tree algorithms suffer from large number of factors as tree algorithms
# need to consider 2^(num level - 1) partitions of levels in each node split. 
# Therefore, it may be useful to reduce the number of factors while keepting 
# the top n most frequent levels. This function replace factor level for low 
# occurrence factor levels.
#
# e.g.)
# > levels(remove_low_cnt_factor_level(iris[1:125, ]$Species, 2, 'low'))
# [1] "setosa"     "versicolor" "low"       
remove_low_cnt_factor_level <- function(data, top_n, replace_val) {
  low_cnt <- names(sort(-table(data)))
  low_cnt <- low_cnt[(top_n + 1):NROW(low_cnt)]
  levels(data)[levels(data) %in% low_cnt] <- replace_val
  return(data)
}

# Fill in NA value in data$col_name, with the default_value.
fill_in_na <- function(data, col_name, default_value) {
  data[, col_name] <- ifelse(
    is.na(data[, col_name]),
    default_value,
    data[, col_name])
  return(data)
}

# Given a data frame, make all columns fixed length strings and split each
# column into columns of n-gram.
# e.g.)
# > df <- data.frame(x=c("abc", "def"),
# +                  y=c("012", "34"),
# +                  stringsAsFactors=FALSE)
# > split_letters_to_ngram_columns(df, 2, pad='Z')
# [,1] [,2] [,3] [,4]
# [1,] "ab" "bc" "01" "12"
# [2,] "de" "ef" "Z3" "34"
split_letters_to_ngram_columns <- function(df, n, pad='0', colname_prefix) {
  df <- lapply(df, function(x) {
    str_pad(x, max(nchar(x)), pad=pad)
  })
  df <- do.call(cbind,
      lapply(df,
             function(col) {
               do.call(cbind,
                       foreach(i=1:(nchar(col[1]) - n + 1)) %do% {
                         substr(col, i, i + n - 1)
                       })
             }))
  df <- as.data.frame(df)
  names(df) <- paste0(colname_prefix, 1:ncol(df))
  return(df)
}

# Convert a factor to multiple columns so that each column has less than 32 levels.
# Column to store factor value is decided by factor_placement. If it's 'decreasing',
# the 32 most frequent factors will be stored in the first columns. Next 32 frequent
# will be stored in the second column, and so on. If it's 'roundrobin', most
# frequent factor will be stored in the first column. Second frequent factor will be
# stored to the second column. This continues until the last column is met. In such
# case, we start over from the first column to store remaining factor levels.
#
# Factors whose frequency is less than min_cnt_threshold will be replaced by a new
# factor level, 'replace_val'.
#
# Return value is a list containig df(columns created by factor) and col_idx_map(
# vector containing the column index of each factor level). col_idx is useful
# when there's necessity to convert the factor in the test data in the same way done 
# for training data. See split_factor_by_col_idx_map() for this purpose.
split_factor_by_cnt <- function(f, min_cnt_threshold, replace_val, colname_prefix,
                                factor_placement=c("decreasing", "roundrobin")) {
  factor_placement <- match.arg(factor_placement)
  max_levels_per_column <- 31  # 1 level is reserved for replace_val.
  cnt <- sort(-table(f))
  cnt <- -cnt
  cnt <- cnt[which(cnt > min_cnt_threshold)]
  num_split_cols <- ceiling(NROW(cnt) / max_levels_per_column) 
  m <- matrix(replace_val, 
              ncol=num_split_cols, 
              nrow=NROW(f))
  col_idx_map <- rep(0, nlevels(f))
  for(i in 1:NROW(f)) {
    # Figure out the ranking of f[i]
    ranking_of_value <- which(names(cnt) == f[i])
    if (NROW(ranking_of_value) != 0) {
      # Factor w/ count more than min_cnt_threshold.
      if (factor_placement == "roundrobin") {
        col_idx <- (ranking_of_value %% num_split_cols) + 1
      } else {  # decreasing
        col_idx <- ceiling(ranking_of_value / max_levels_per_column)
      }
      m[i, col_idx] <- levels(f)[f[i]]
      col_idx_map[as.numeric(f[i])] <- col_idx
    } else {
      # Factor w/ count less than min_cnt_threshold.
      col_idx_map[as.numeric(f[i])] <- 0
    }
  }
  df <- data.frame(m)
  names(df) <- paste0(colname_prefix, 1:ncol(df))
  return(list(df=df, col_idx_map=col_idx_map))
}

# Split factor into multiple columns using col_idx_map which contains mapping between
# factor level and column index to store the factor value. col_idx_map is generated 
# by split_factor_by_cnt, and this function is useful to apply the same split logic 
# to test data after splitting factor for training data using split_factor_by_cnt().
#
# After applying this function, it will be necessary to run merge_factor_levels() to 
# new columns of train and test so that factor levels are matched. Otherwise,
# ML algorithms may throw an error complaining that factor level are not matched.
split_factor_by_col_idx_map <- function(f, col_idx_map, replace_val, colname_prefix) {
  m <- matrix(replace_val, ncol=max(col_idx_map), nrow=NROW(f))
  for(i in 1:NROW(f)) {
    col_idx <- col_idx_map[as.numeric(f[i])]
    m[i, col_idx] <- levels(f)[f[i]]
  }
  df <- data.frame(m)
  names(df) <- paste0(colname_prefix, 1:ncol(df))
  return(df)
}