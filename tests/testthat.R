library(testthat)
library(capsule)

# test utils
sort_by_name <- function(named) {
  named[sort(names(named))]
}

test_check("capsule")
