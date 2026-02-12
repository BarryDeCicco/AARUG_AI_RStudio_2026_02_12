# Get all objects in the global environment
all_objects <- ls()

# Filter to data frames and other data objects
data_objects <- sapply(all_objects, function(x) {
  obj <- get(x)
  class(obj)[1]
})

# Filter for common data structures
data_types <- c("data.frame", "tbl_df", "tbl", "matrix", "tibble", "data.table")
datasets <- data_objects[data_objects %in% data_types]

if (length(datasets) == 0) {
  cat("No datasets found in the current environment.\n")
} else {
  cat("Datasets in the current environment:\n\n")
  for (name in names(datasets)) {
    obj <- get(name)
    if (is.data.frame(obj) || inherits(obj, "tbl")) {
      dims <- dim(obj)
      cat(sprintf("- %s (%s): %d rows × %d columns\n",
                  name, datasets[name], dims[1], dims[2]))
    } else if (is.matrix(obj)) {
      dims <- dim(obj)
      cat(sprintf("- %s (matrix): %d rows × %d columns\n",
                  name, dims[1], dims[2]))
    } else {
      cat(sprintf("- %s (%s)\n", name, datasets[name]))
    }
  }
}
