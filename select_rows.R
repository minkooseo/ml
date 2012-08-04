# Get num_data_for_each_label rows for each class.
get_partial_data <- function(data, num_data_for_each_label) {
  data.by.label <- split(data, data$label)
  list_of_df_for_each_label = lapply(1:nlevels(data$label), function(l) {
    data.by.label[[l]][1:num_data_for_each_label,]
  })
  return(do.call('rbind', list_of_df_for_each_label))
}
