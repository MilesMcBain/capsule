##' Recreate a capsule with new dependencies
##'
##' After some development work has been completed, Use this function to update the
##' capsule environment to match the dependency versions in your development
##' environment.
##'
##' Similarly to `create()`, you are expected to supply a vector of files in
##' your project to extract dependencies from. Things work best when this is a
##' single file containing only dependency related code.
##' 
##' @title recreate
##' @param dep_source_paths a character vector of project source files to
##'   extract dependencies from.
##' @return nothing. The capsule is regenerated as a side effect.
##' @author Miles McBain
##' @seealso [create()]
##' @export
recreate <- function(dep_source_paths = "./packages.R") {

  delete()
  create(dep_source_paths = dep_source_paths)

}
