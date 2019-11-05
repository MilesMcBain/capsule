##' Reproduce the capsule library from the lockfile
##'
##' If you have cloned a project that contains a lockfile you can actually just
##'   use `run()` to execute commands in the capsule and have the library built
##'   automatically. If that is not convenient, this will explicitly create the
##'   capsule library from the lockfile.
##' 
##' @title reproduce_lib
##' @return nothing.
##' @author Miles McBain
##' @export
reproduce_lib <- function() {

  if (dir.exists(renv::paths$library())) stop("[capsule] I found a capsule library. Try creating the library first.R")

  callr::r(function(){
    renv::init(bare = TRUE)
    renv::deactivate()
  })
  delete_unneeded()
  renv::restore(project = getwd(),
                library = renv::paths$library(),
                confirm = FALSE)

}


