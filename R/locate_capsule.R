locate_capsule <- function() {

  renv_libraries <-
    list.files(pattern = "^.renv", recursive = TRUE, include.dirs = TRUE, all.files = TRUE)

  if (length(renv_libraries) == 0) {
    stop("could not find a capsule local library (looking for .renv inside)")

  }

  if (length(renv_libraries) > 1) {
    stop(
      "found multiple renv local libraries ",
      paste0(renv_libaries, collapse = ", "),
      "comparing",
      renv_libraries[[1]]
    )
  }

  path_parts <- fs::path_split(renv_libraries[[1]])[[1]]
  fs::path_join(head(path_parts, -1)) # remove .renv
}

capsule_exists <- function() {
  library_locations <-
    list.files(pattern = "^.renv", recursive = TRUE, include.dirs = TRUE, all.files = TRUE)

  length(library_locations) > 0
}
