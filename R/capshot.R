globalVariables("BASE_PACKAGES")

BASE_PACKAGES <-
  c("class",
  "coxme",
  "KernSmooth",
  "MASS",
  "base",
  "boot",
  "class",
  "cluster",
  "codetools",
  "compiler",
  "datasets",
  "foreign",
  "graphics",
  "grDevices",
  "grid",
  "KernSmooth",
  "lattice",
  "MASS",
  "Matrix",
  "methods",
  "mgcv",
  "nlme",
  "nnet",
  "parallel",
  "rpart",
  "spatial",
  "splines",
  "stats",
  "stats4",
  "survival",
  "tcltk",
  "tools",
  "utils")

#' Quickly generate an renv compliant lock file
#'
#' These functions generate json lockfiles that can be restored from using
#' `capsule` or `renv`.
#'
#' Unlike [capsule::create()] this function does not populate a local library.
#' It writes a lock file using dependencies found in files in `dep_source_paths`.
#' Package dependency information is mined from DESCRIPTION files using the
#' current [.libPaths()].
#'
#' These functions do not use `{renv}` machinery and so may produce
#' different results. They have been re-implmented for speed, so that they can
#' be integrated into automated pipelines that build projects or documents.
#'
#' @param dep_source_paths files to scan for project dependencies to write to the lock file.
#' @param lockfile_path output path for the lock file.
#' @param minify a boolean value indicicating if lockfile JSON should have whitespace removed to shrink footprint.
#'
#' @return `lockfile_path`. Writes lockfile as a side effect.
#' @export
capshot <- function(
  dep_source_paths = "./packages.R",
  lockfile_path = "./renv.lock",
  minify = FALSE
) {

  lockfile_json <- capshot_str(dep_source_paths, minify)
  writeLines(lockfile_json, lockfile_path)
  invisible(lockfile_path)
}


#' @describeIn capshot a variation that returns lockfile json as a character vector for further use.
#' @export
capshot_str <- function(dep_source_paths = "./packages.R", minify = FALSE) {
  generate_lockfile_json(
    get_project_deps(detect_dependencies(dep_source_paths)),
    minify = minify
  )
}

get_project_deps <- function(declared_deps) {
  pkg_dcfs <-
    lapply(
      Sys.glob(file.path(.libPaths(), "*", "DESCRIPTION")),
      read.dcf
    )

  pkg_names <- unlist(lapply(pkg_dcfs, function(x) x[, "Package"]))
  pkg_dcfs <- pkg_dcfs[!duplicated(pkg_names)]
  pkg_names <- pkg_names[!duplicated(pkg_names)]
  project_dep_dcfs <- get_project_dcfs(declared_deps, pkg_names, pkg_dcfs)
  project_dep_dcfs
}

get_project_dcfs <- function(declared_deps, pkg_names, pkg_dcfs) {
  pkg_deps <- stats::setNames(lapply(pkg_dcfs, get_deps), pkg_names)
  project_deps <- stats::setNames(as.list(logical(length(pkg_names))), pkg_names)
  current_deps <- declared_deps

  while (length(current_deps) > 0) {
    project_deps[current_deps] <- TRUE
    new_current_deps <- setdiff(
      unlist(pkg_deps[current_deps], use.names = FALSE),
      names(Filter(isTRUE, project_deps))
    )
    current_deps <- new_current_deps
  }
  missing <- setdiff(names(project_deps), unlist(pkg_names))
  if (length(missing)) stop("Cannot complete capshot(). Project dependencies not installed locally: ", 
  paste(missing, collapse = ", "), "\n\n",
  "Use dev_mirror_lockfile() to bring the local library up to at least the lockfile versions for all dependencies."
  )
  stats::setNames(pkg_dcfs, pkg_names)[unlist(project_deps)]
}

parse_pkg_deps <- function(dep_string) {
  deps <- regmatches(
    dep_string,
    gregexpr(pattern = "[A-Za-z][A-Za-z0-9.]+", dep_string)
  )[[1]]

  setdiff(deps, "R")
}

get_deps <- function(
  dcf_data,
  fields = c("Imports", "Depends", "LinkingTo")
) {

  present_fields <- intersect(fields, colnames(dcf_data))
  parse_pkg_deps(
    paste0(dcf_data[, present_fields], collapse = " ")
  )
}



generate_lockfile_json <- function(project_dep_dcfs, minify = FALSE) {
  is_base <- names(project_dep_dcfs) %in% BASE_PACKAGES
  project_dep_dcfs <- project_dep_dcfs[!is_base]
  pkg_renv_entries <- lapply(project_dep_dcfs, get_renv_fields)
  r_renv_entry <- get_renv_r_entry()
  jsonlite::toJSON(
    list(
      R = r_renv_entry,
      Packages = pkg_renv_entries
    ),
    pretty = !minify,
    auto_unbox = TRUE
  )
}

# This implementation tries to follow logic in
# renv:::renv_snapshot_description_source
# https://github.com/rstudio/renv/blob/master/R/snapshot.R
get_renv_fields <- function(dcf_record) {
  dcf_record_df <- as.data.frame(dcf_record)
  if (!is.null(dcf_record_df$RemoteType)) {
    dcf_record_df$Source <- renv:::renv_alias(dcf_record_df$RemoteType)
  } else if (!is.null(dcf_record_df$Repository)) {
    if (identical(dcf_record_df$Repository, "Local")) {
      dcf_record_df$Source <- "Local"
    }
    else {
      dcf_record_df$Source <- "Repository"
    }
  } else if (!is.null(dcf_record_df$biocViews)) {
    dcf_record_df$Source <- "BioConductor"
  } else {
    dcf_record_df$Source <- "unknown"
  }
  renv_fields <- c(
    "Source",
    "Package",
    "Version",
    "Repository",
    "OS_type",
    colnames(dcf_record_df)[grepl("^Remote(?!s$)", colnames(dcf_record_df), perl = TRUE)]
  )
  as.list(dcf_record_df[, intersect(renv_fields, colnames(dcf_record_df))])

}

get_renv_r_entry <- function() {
  list(
    Version = paste0(R.Version()[c("major", "minor")], collapse = "."),
    Repositories = get_repos()
  )
}

get_repos <- function() {
  repos <- getOption("repos")
  # if you have none, default one
  repos[repos == "@CRAN@"] <- "https://cloud.r-project.org"
  mapply(
    function(repo, reponame) list(Name = reponame, URL = repo),
    repos,
    names(repos),
    USE.NAMES = FALSE,
    SIMPLIFY = FALSE
  )
}

# Test code
function() {
  lockfile <-
    capshot("../coolburn_dashboard/packages.R", lockfile_path = "renv.lock", minify = TRUE)
  lockfile

  dummy <- c("Remotes", "RemoteSha", "RemoteUsername", "RemotePkgRef")
  grepl("^Remote(?!s$)", dummy, perl = TRUE)
}

