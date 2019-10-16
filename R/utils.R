system_library <- function() {

  purrr::keep(.libPaths(),
              ~fs::path_has_parent(., Sys.getenv("R_HOME"))
              )

}
