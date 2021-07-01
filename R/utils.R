system_libraries <- function() {

  purrr::keep(
    .libPaths(),
    ~ fs::path_has_parent(., Sys.getenv("R_HOME"))
  )

}

delete_unneeded <- function() {

  unlink("./.Rbuildignore")
  unlink("./renv/activate.R")
  unlink("./renv/settings.dcf")

}

`%||%` <- function(lhs, rhs) {
  if (is.null(lhs)) rhs else lhs
}

assert_files_exist <- function(...) {
  files <- unlist(list(...))
  missing_files <- !file.exists(files)
  if (any(missing_files)) {
    stop(
      "Required files are missing: ",
      paste0(files[missing_files], collapse = ", ")
    )
  }
}
