get_pkg_behind_capsule <- function(dep_source_paths = "./packages.R",
                                  lockfile_path = "./renv.lock") {
    package_data <- compare_dev_capsule(dep_source_paths, lockfile_path)

    behind <-
        purrr::pmap_lgl(
            package_data,
            function(...) {
                data_row <- list(...)
                version_comp <- compareVersion(data_row$version_cap, data_row$version_rlib)

                # catch edge case with git remotes not updating version and warn.
                # if the versions are equal but:
                # * one has a remote sha and one does not -
                #   i.e. one is from CRAN and one is from GitHub
                # * both have remote shas and they are not equal
                if (version_comp == 0 &&
                    (!is.na(data_row$remote_sha_cap) || !is.na(data_row$remote_sha_rlib)) &&
                    !isTRUE(data_row$remote_sha_cap == data_row$remote_sha_rlib)) {
                    warning(
                        "Packages have equal versions but different remote SHAs: ",
                        data_row$name
                    )
                }

                if (version_comp == 1) TRUE else FALSE
            }
        )

    package_data$behind <- behind

    package_data[behind, ]
}

any_pkg_behind_capsule <- function(dep_source_paths = "./packages.R", 
    lockfile_path = "./renv.lock") {
        nrow(get_pkg_behind_capsule(dep_source_paths, lockfile_path)) > 0
    }

compare_dev_capsule <- function(dep_source_paths = "./packages.R", lockfile_path = "./renv.lock") {
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
            "but not menitoned in the lock file: ", paste(packages_not_in_lock)
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
                            repository = lib_data$Repository %||% lib_data$RemoteHost %||% NA,
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