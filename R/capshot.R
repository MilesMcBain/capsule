capshot <- function(dep_source_paths = "./packages.R") {

    renv::snapshot(
      packages = detect_dependencies(dep_source_paths)
    )

}

capshot_str <- function(dep_source_paths = "./packages.R") {

    renv::snapshot(
      packages = detect_dependencies(dep_source_paths),
      reprex = TRUE
    )

}