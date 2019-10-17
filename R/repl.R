##' Open a REPL within the capsule
##'
##' Uses an experimental feature from `callr` to attach a new process repl to
##' your current interactive session. That REPL evaluates code within the
##' context of your capsule.
##'
##' To exit the process send the use the interrupt signal in the REPL e.g.
##' Control-C, or, ess-interrupt, or the 'stop' button in rstudio.
##'
##' Depending on your R editor, overtaking your REPL with a new process may
##' cause strang behaviour, like the loss of autocompletions.
##' 
##' @title repl
##' @return nothing.
##' @author Miles McBain
##' @export
repl <- function() {

  session_options <- callr::r_session_options()
  session_options$libpath <- c(renv::paths$library(), system_libraries())
  capsule <- callr::r_session$new(options = session_options, wait = TRUE)
  capsule$attach()

}
