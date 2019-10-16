repl <- function() {

  session_options <- callr::r_session_options()
  session_options$libpath <- c(renv::paths$library(), system_library())
  capsule <- callr::r_session$new(options = session_options, wait = TRUE)
  capsule$attach()

}
