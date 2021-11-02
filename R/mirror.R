#' Mirror lockfile in local library
#'
#' Install packages contained in the lockfile that are either missing from the local library or at a lower version number.
#' 
#' Packages are installed at the lockfile version. Packages in the local library that are ahead of the the local library are not touched.
#' 
#' So this function ensures that the local development environment is **at least** at the lockfile version of all packages, not **equal to**.
#' 
#' To find differences between the local library and the lockfile versions use compare_
#'
#' @param lockfile_path DESCRIPTION.
#' @param dep_source_paths DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
dev_mirror_lockfile <- function(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL
) {
  lockfile_deps <- get_pkg_behind_capsule(lockfile_path, dep_source_paths)
  
  packages_to_update <- lockfile_deps$name
  message(length(packages_to_update), " to be updated to lockfile versions...")

  if (length(packages_to_update) == 0) return(invisible(character(0)))

  renv::restore(packages = packages_to_update, prompt = FALSE)
  invisible(packages_to_update)
}