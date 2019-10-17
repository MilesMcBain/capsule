##' Delete the capsule's local library
##'
##' This helper is provided to help you recover from mistakes or test building
##' the library from a lockfile you have generated.
##'
##' @title  delete_local_lib
##' @return nothing
##' @seealso [delete()]
##' @author Miles McBain
##' @export
delete_local_lib <- function() {

  unlink("./renv",
         recursive = TRUE)

}
##' Delete the capule's lockfile
##'
##' This helper is provided to help you recover from mistakes or test extracting
##' dependencies.
##' 
##' @title delete_lockfile
##' @return nothing
##' @export
##' @author Miles McBain
delete_lockfile <- function() {

  unlink("./renv.lock")

}
##' Delete the capsule
##'
##' Removes the lockfile and library, in the case that you made a mistake or no
##' longer want to use capsule.
##' 
##' @title delete
##' @return nothing
##' @author Miles McBain
##' @export
delete <- function() {

  delete_local_lib()
  delete_lockfile()

}
