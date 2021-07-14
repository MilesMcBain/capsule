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

get_my_deps <- function(){
  pkg_dcfs <- 
    lapply(
      Sys.glob(file.path(.libPaths(),"*","DESCRIPTION")),
      read.dcf)

  pkg_names <- unlist(lapply(pkg_dcfs, function(x)  x[,"Package"]))
  pkg_dcfs <- pkg_dcfs[!duplicated(pkg_names)]
  pkg_names <- pkg_names[!duplicated(pkg_names)]
  project_dep_dcfs <- get_project_dcfs(declared_deps, pkg_names, pkg_dcfs)
  project_dep_dcfs
}

get_project_dcfs <- function(declared_deps, pkg_names, pkg_dcfs) {
  pkg_deps <- setNames(lapply(pkg_dcfs, get_deps), pkg_names)
  project_deps <- setNames(as.list(logical(length(pkg_names))), pkg_names)
  current_deps <- declared_deps
  
  while(length(current_deps) > 0) {
    project_deps[current_deps] <- TRUE
    new_current_deps <- setdiff(unlist(pkg_deps[current_deps], use.names = FALSE), 
                                names(Filter(isTRUE, project_deps)))
    current_deps <- new_current_deps
  }
  setNames(pkg_dcfs, pkg_names)[unlist(project_deps)]
}

parse_pkg_deps <- function(dep_string) {
  deps <- regmatches(
    dep_string,
    gregexpr(pattern ="[A-Za-z][A-Za-z0-9.]+", dep_string)
    )[[1]]

  setdiff(deps, "R")
}

get_deps <- function(dcf_data, 
                     fields = c("Imports", "Depends", "LinkingTo")) {

   present_fields <- intersect(fields, colnames(dcf_data))
   parse_pkg_deps(
     paste0(dcf_data[, present_fields], collapse = " ")
   )
}

BASE_PACKAGES <- 
c("base",
  "compiler",
  "datasets",
  "graphics",
  "grDevices",
  "grid",
  "methods",
  "parallel",
  "splines",
  "stats",
  "stats4",
  "tcltk",
  "tools",
  "utils")
