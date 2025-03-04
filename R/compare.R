#' get packckes behind lockfile
#'
#' return information on packages in your main R library (`.libPaths()`) or capsule library (`./renv`) that are behind the
#' lockfile versions (at `lockfile_path`).
#'
#' if `dep_source_paths` is supplied only dependencies declared in these files are returned.
#'
#' Information is returned about packages that are behind in your development
#' environment, so you can update them to the capsule versions if you wish.
#'
#' A warning is thrown in the case that pacakges have the same version but
#' different remote SHA. E.g. A package in one library is from GitHub and in
#' the other library is from CRAN. Or Both packages are from GitHub, have the
#' same version but different SHAs.
#'
#' @param dep_source_paths a character vector of file paths to extract
#'     package dependencies from. If NULL (default) the whole local library is compared.
#' @param lockfile_path a length one character vector path of the lockfile for
#      the capsule.
#' @param library_path the source libary to compare versions from.
#'
#' @return a summary dataframe of package version differences.
#' @examples
#' \dontrun{
#' get_local_behind_capsule(
#'   dep_source_paths = "./packages.R",
#'   lockfile_path = "./renv.lock"
#' )
#' }
#' @export
#' @family comparisons
#' @rdname get_behind
get_local_behind_lockfile <- function(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL,
  library_path = .libPaths()
) {
  get_pkg_behind_lockfile(lockfile_path, dep_source_paths, library_path)
}

#' @family comparisons
#' @describeIn get_behind get packages in the renv library that are behind the lockfile
#' @export
get_capsule_behind_lockfile <- function(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL
) {
  get_pkg_behind_lockfile(
    lockfile_path,
    dep_source_paths,
    library_path = locate_capsule())
}

get_pkg_behind_lockfile <- function(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL,
  library_path = .libPaths()
) {
  assert_files_exist(lockfile_path)
  package_data <- compare_lib_lockfile(lockfile_path, library_path)

  if (!is.null(dep_source_paths)) {
    assert_files_exist(dep_source_paths)
    declared_dependencies <-
      detect_dependencies(dep_source_paths)
    package_data <-
      package_data[package_data$name %in% declared_dependencies, ]
  }

  behind <-
    .mapply(
      dots = package_data,
      MoreArgs = NULL,
      FUN = function(...) {
        data_row <- list(...)
        version_comp <- utils::compareVersion(
          data_row$version_lock,
          data_row$version_lib
        )

        # catch edge case with git remotes not updating version and
        # warn if the versions are equal but:
        # * one has a remote sha and one does not -
        #   i.e. one is from CRAN and one is from GitHub
        # * both have remote shas and they are not equal
        if (version_comp == 0 &&
          (
            (!is.na(data_row$remote_sha_lock)) ||
            (!is.na(data_row$remote_sha_lib))
          ) &&
          !isTRUE(data_row$remote_sha_lock == data_row$remote_sha_lib)) {
          warning(
            "Packages have equal versions but different",
            " remote SHAs: ",
            data_row$name,
            call. = FALSE
          )
        }

        if (version_comp == 1) TRUE else FALSE
      }
    )

  package_data$behind <- unlist(behind)

  package_data[package_data$behind, ]
}

#' check if any local packages are behind lockfile
#'
#' A wrapper for [get_local_behind_lockfile] that returns TRUE if any
#' dependencies found in `dep_source_paths` are behind the lockfile version in
#' `lockfile_path`
#'
#' @inheritParams get_local_behind_lockfile
#'
#' @return TRUE if dev packages are behind lockfile, FALSE otherwise.
#' @family comparisons
#' @export
any_local_behind_lockfile <- function(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL
) {
  nrow(get_local_behind_lockfile(lockfile_path, dep_source_paths)) > 0
}

assert_not_behind_lockfile <- function(
  lockfile_path = "./renv.lock",
  dep_source_paths = NULL,
  stop_on_behind = FALSE
) {
  if (!file.exists(lockfile_path)) {
    warning("No renv.lock found in this project.")
    return(FALSE)
  }
  packages_behind_lockfile <- get_pkg_behind_lockfile(lockfile_path, dep_source_paths)
  if (nrow(packages_behind_lockfile) == 0) {
    message("No installed packages are behind renv.lock")
  } else {
    action_fun <- if (stop_on_behind) stop else warning
    action_fun(
      "Found packages with versions behind renv.lock: ",
      paste0(packages_behind_lockfile$name, collapse = ", ")
    )
  }

}


#' compare the local R library with the lockfile
#'
#' Get a summary dataframe comparing package versions in the lockfile with
#' versions in the local R library (.libPaths()) or capsule library (./renv).
#'
#' @inheritParams get_local_behind_lockfile
#' @return a summary dataframe of version differences
#'
#' @export
#' @family comparisons
#' @rdname compare_lockfile
compare_local_to_lockfile <- function(lockfile_path = "./renv.lock") {
  compare_lib_lockfile(
    lockfile_path,
    library_path = .libPaths())
}

#' @export
#' @family comparisons
#' @describeIn compare_lockfile compares the renv libray to the lockfile
compare_capsule_to_lockfile <- function(lockfile_path = "./renv.lock") {
  compare_lib_lockfile(
    lockfile_path,
    library_path = locate_capsule()
  )

}

#' @param library_path a character vector of library paths to search
compare_lib_lockfile <- function(
  lockfile_path = "./renv.lock",
  library_path = .libPaths()
) {
  lockfile_deps <- get_lockfile_deps(lockfile_path)

  local_deps <- get_library_deps(lockfile_deps$name, library_path)

  merge(lockfile_deps, local_deps, by = "name", suffixes = c("_lock", "_lib"))
}


get_lockfile_deps <- function(lockfile_path) {
  lockfile <- jsonlite::read_json(lockfile_path)

  lockfile_deps <- lapply_df(
    lockfile$Packages[],
    dependency_data_frame
  )

  lockfile_deps
}

#' @param library_path a character vector of library paths to search
get_library_deps <- function(dep_list, library_path = NULL) {
  local_deps <-
    lapply_df(
      dep_list,
      function(dep_name) {
        tryCatch(
          {
            lib_data <- as.data.frame(read.dcf(file.path(
              find.package(dep_name, lib.loc = library_path),
              "DESCRIPTION"
            )))
            dependency_data_frame(
              lib_data
            )
          },
          error = function(e) {
            dependency_data_frame(
              list(
                Package = dep_name
              )
            )
          }
        )
      }
    )
}

dependency_data_frame <- function(dep_data) {

  data.frame(
    name = dep_data$Package %||% NA,
    version = dep_data$Version %||% NA,
    repository = dep_data$Repository %||%
      dep_data$RemoteHost %||% NA,
    remote_sha = ifelse(is_real_sha(dep_data$RemoteSha), dep_data$RemoteSha, NA),
    remote_repo = dep_data$RemoteRepo %||% NA,
    remote_username = dep_data$RemoteUsername %||% NA
  )

}
