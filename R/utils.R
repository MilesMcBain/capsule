system_libraries <- function() {

  purrr::keep(.libPaths(),
              ~fs::path_has_parent(., Sys.getenv("R_HOME"))
              )

}

delete_unneeded <- function() {

  unlink("./.Rbuildignore")
  unlink("./renv/activate.R")
  unlink("./renv/settings.dcf")

}
