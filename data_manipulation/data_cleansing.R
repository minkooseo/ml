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
