detect_dependencies <- function(file_path) {

  renv_deps <-
    renv::dependencies(file_path, progress = FALSE)

  using_deps <-
    lapply_df(file_path, using::detect_dependencies)

  unique(c(renv_deps$Package,
           using_deps$package))

}



