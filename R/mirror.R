#' Mirror lockfile in local library
#'
#' Install packages contained in the lockfile that are either missing from the local library or at a lower version number.
#'
#' Packages are installed at the lockfile version. Packages in the local library that are ahead of the the local library are not touched.
#'
#' So this function ensures that the local development environment is **at least** at the lockfile version of all packages, not **equal to**.
#'
#' To find differences between the local library and the lockfile versions use [compare_local_to_lockfile()].
#'
#' @param lockfile_path lockfile to be compared to local environment.
#' @param dep_source_paths R files to search for dependencies, the set of packages to be updated is limited to these dependencies (and their dependencies).
#' @param prompt ask for confirmation after displaying list to be installed and before isntalling?
#'
#' @return names of the packages updated or to be updated (if install did not proceed) invisibly.
#' @export
dev_mirror_lockfile <- function(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL,
  prompt = interactive()
) {
  with_.env_if_available({
    lockfile_deps <- get_pkg_behind_lockfile(lockfile_path, dep_source_paths)

    packages_to_update <- lockfile_deps$name
    if (length(packages_to_update) == 0) {
      cat("No packages to update.\n")
      return(invisible(character(0)))
    }

    cat(
      length(packages_to_update),
      "packages to be updated to lockfile versions:\n"
    )
    cat(
      paste(
        format(lockfile_deps$name),
        format(lockfile_deps$version_lib),
        " -> ",
        format(lockfile_deps$version_lock)
      ),
      sep = "\n"
    )
    proceed <- utils::menu(choices = c("Yes", "No"), title = "Proceed with installation?")

    if (proceed == 2) {
      return(invisible(packages_to_update))
    }
    renv::restore(packages = packages_to_update, prompt = FALSE)
    invisible(packages_to_update)
  })
}

#' Complain if the local R library has packages that are behind the lockfile versions
#'
#' Useful for keeping teams loosely in sync on package versions. A warning can
#' be tolerated until updating at a convenient time. For example if
#' placed in the packages.R file of a `{tflow}` project.
#'
#' The message is hardcoded, but the whinge_fun that takes the message is customisable.
#'
#' @param whinge_fun the function to use to have a whinge about packages, e.g. message, warning, stop, etc.
#' @param lockfile_path the path to the project lockfile
#' @return output of whinge_fun, most likely nothing.
#' @export
whinge <- function(whinge_fun = warning, lockfile_path = "./renv.lock") {
  if (any_local_behind_lockfile(lockfile_path)) {
    whinge_fun(
      "[{capsule} whinge] Your R library packages are behind the lockfile.",
      " Use capsule::dev_mirror_lockfile to upgrade."
    )
  }
}

function() {
  withr::with_dir(
    "../analytics_aws_data_export",
    lockfile_deps <- get_pkg_behind_lockfile()
  )
  withr::with_dir(
    "../analytics_aws_data_export",
    dev_mirror_lockfile()
  )
}
