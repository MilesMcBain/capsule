#' get packckes behind capsule
#'
#' Check versions of packages referred to in your project's `dep_source_paths`
#' and identify and in your main R library that are behind the capsule
#' renv.lock at `lockfile_path`.
#'
#' Information is returned about packages that are behind in your development
#' environment, so you can update them to the capsule versions if you wish.
#'
#' A warning is thrown in the case that pacakges have the same version but
#' different remote SHA. E.g. A package in one library is from GitHub and in
#' the other library is from CRAN. Or Both packages are from GitHub, have the
#' same version but different SHAs.
#' @param dep_source_paths a character vector of file paths to extract
#'     package dependencies from.
#' @param lockfile_path a length one character vector path of the lockfile for
#      the capsule.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' \dontrun{
#' get_pkg_behind_capsule(
#'   dep_source_paths = "./packages.R",
#'   lockfile_path = "./renv.lock"
#' )
#' }
#' @export
get_pkg_behind_capsule <- function(
  dep_source_paths = "./packages.R",
  lockfile_path = "./renv.lock"
) {
  assert_files_exist(dep_source_paths, lockfile_path)
  package_data <- compare_dev_capsule(dep_source_paths, lockfile_path)

  behind <-
    purrr::pmap_lgl(
      package_data,
      function(...) {
        data_row <- list(...)
        version_comp <- utils::compareVersion(
          data_row$version_cap,
          data_row$version_rlib
        )

        # catch edge case with git remotes not updating version and
        # warn if the versions are equal but:
        # * one has a remote sha and one does not -
        #   i.e. one is from CRAN and one is from GitHub
        # * both have remote shas and they are not equal
        if (version_comp == 0 &&
          (!is.na(data_row$remote_sha_cap) ||
            !is.na(data_row$remote_sha_rlib)) &&
          !isTRUE(data_row$remote_sha_cap == data_row$remote_sha_rlib)) {
          warning(
            "Packages have equal versions but different",
            " remote SHAs: ",
            data_row$name
          )
        }

        if (version_comp == 1) TRUE else FALSE
      }
    )

  package_data$behind <- behind

  package_data[behind, ]
}


#' check if any packages are behind capsule
#'
#' A wrapper for [get_pkg_behind_capsule] that returns TRUE if any
#' dependencies found in `dep_source_paths` are behind the lockfile version in
#' `lockfile_path`
#'
#' @inheritParams get_pkg_behind_capsule
#'
#' @return TRUE if dev packages are behind capsule, FALSE otherwise.
#' @examples
#' # ADD_EXAMPLES_HERE
any_pkg_behind_capsule <- function(
  dep_source_paths = "./packages.R",
  lockfile_path = "./renv.lock"
) {
  nrow(get_pkg_behind_capsule(dep_source_paths, lockfile_path)) > 0
}

assert_not_behind_lockfile <- function(
  dep_source_paths = "./packages.R",
  lockfile_path = "./renv.lock",
  stop_on_behind = FALSE
) {
  if (!file.exists(lockfile_path)) {
    warning("No renv.lock found in this project.")
    return(FALSE)
  }
  packages_behind_lockfile <- get_pkg_behind_capsule(dep_source_paths, lockfile_path)
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

compare_dev_capsule <- function(
  dep_source_paths = "./packages.R",
  lockfile_path = "./renv.lock"
) {
  dep_list <- detect_dependencies(dep_source_paths)

  lockfile_deps <- get_lockfile_deps(dep_list, lockfile_path)

  local_deps <- get_local_deps(dep_list)

  merge(lockfile_deps, local_deps, by = "name", suffixes = c("_cap", "_rlib"))
}

get_lockfile_deps <- function(dep_list, lockfile_path) {
  lockfile <- jsonlite::read_json(lockfile_path)

  lockfile_package_names <- purrr::map_chr(lockfile$Packages, "Package")

  packages_not_in_lock <- setdiff(dep_list, lockfile_package_names)

  if (length(packages_not_in_lock) > 0) {
    warning(
      "Packages are called in source, ",
      "but not menitoned in the lock file: ",
      paste(packages_not_in_lock)
    )
  }

  lockfile_deps <- purrr::map_dfr(
    lockfile$Packages[
      intersect(dep_list, lockfile_package_names)
    ],
    function(pkgdata) {
      data.frame(
        name = pkgdata$Package %||% NA,
        version = pkgdata$Version %||% NA,
        repository = pkgdata$Repository %||% pkgdata$RemoteHost %||% NA,
        remote_sha = pkgdata$RemoteSha %||% NA,
        remote_repo = pkgdata$RemoteRepo %||% NA,
        remote_username = pkgdata$RemoteUsername %||% NA
      )
    }
  )

  lockfile_deps
}

get_local_deps <- function(dep_list) {
  local_deps <-
    purrr::map_dfr(
      dep_list,
      function(dep_name) {
        tryCatch(
          {
            lib_data <- as.data.frame(read.dcf(file.path(
              find.package(dep_name),
              "DESCRIPTION"
            )))

            data.frame(
              name = lib_data$Package,
              version = lib_data$Version,
              repository = lib_data$Repository %||%
                lib_data$RemoteHost %||% NA,
              remote_sha = lib_data$RemoteSha %||% NA,
              remote_repo = lib_data$RemoteRepo %||% NA,
              remote_username = lib_data$RemoteUsername %||% NA
            )
          },
          error = function(e) {
            data.frame(
              name = dep_name,
              version = NA,
              repository = NA,
              remote_sha = NA,
              remote_repo = NA,
              remote_username = NA
            )
          }
        )
      }
    )
}

# dev stuff
function() {
  dep_source_paths <- "../../repos/Camp_Hill_station_replacement/packages.R"
  lockfile_path <- "../../repos/Camp_Hill_station_replacement/renv.lock"

  get_pkg_behind_capsule(dep_source_paths, lockfile_path)

  any_pkg_behind_capsule(dep_source_paths, lockfile_path)

  find.package("qfesdata")

  desc_file <- read.dcf(file.path(
    find.package("mapdeck"),
    "DESCRIPTION"
  ))

  desc_file[, "Version"]

  as.data.frame(desc_file)
}
