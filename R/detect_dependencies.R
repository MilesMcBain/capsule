#' Detect dependencies in nominated R or Rmd files.
#'
#' Get the names of R packages referred to in `file_path`. `file_path` can be a
#' vector of paths if you need, although I advise keeping dependency calls in a
#' single file for R projects.
#'
#' This is a thin wrapper around `[renv::dependencies()]` that includes support
#' for the `[using::pkg()]` style specification via `[using::detect_dependencies()]`
#' @param file_path the file(s) to detect dependencies in.
#' @return a character vector of package names 
#' @export
detect_dependencies <- function(file_path) {

  renv_deps <-
    renv::dependencies(file_path, progress = FALSE)

  using_deps <-
    lapply_df(file_path, using::detect_dependencies)

  unique(c(renv_deps$Package,
           using_deps$package))

}
