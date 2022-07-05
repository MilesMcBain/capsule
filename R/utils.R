system_libraries <- function() {

  Filter(
    function(x) fs::path_has_parent(x, Sys.getenv("R_HOME")),
    .libPaths()
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

lapply_df <- function(vec, fn, ...) {
  do.call(
    rbind,
    lapply(vec, fn, ...)
  )
}

# detect the case where some package install tools store the version number in the remoteSha field. 
is_real_sha <- function(sha) {
  !grepl("\\.", sha)
}
