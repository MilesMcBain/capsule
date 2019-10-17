system_libraries <- function() {

  purrr::keep(.libPaths(),
              ~fs::path_has_parent(., Sys.getenv("R_HOME"))
              )

}

delete_uneeded <- function() {

  unlink("./renv/activate.R")
  unlink("./renv/settings.dcf")

}
