##' Create a capsule library context to run code in
##'
##' Dependencies to be encapsulated are detected from files you nominate in
##' `dep_source_paths`. Good practice would be to have a single dependencies R
##' file that contains all library() calls - hence this makes an explicit
##' assertion of your dependencies. This way spurious usages of pkg:: for
##' packages not stated as dependencies will cause errors that can be caught.
##' 
##' @title create
##' @param dep_source_paths files to find package dependencies in.
##' @return nothing. Creates a capsule as a side effect.
##' @author Miles McBain
##' @export
create <- function(
  dep_source_paths = "./packages.R",
  lockfile_path = "./renv.lock"
) {

  if (file.exists(lockfile_path)) {
    warning("Found an existing lockfile, ", 
        lockfile_path,
        ", that will be ovewritten.")
  }
  capshot(
    dep_source_paths = dep_source_paths,
    lockfile_path = lockfile_path
  )
  reproduce_lib(
    dep_source_paths = dep_source_paths,
    lockfile_path = lockfile_path
  )
}
