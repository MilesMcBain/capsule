##' Get the default files from which to detect dependencies
##'
##' Dependencies to be encapsulated are detected from R files in your repository.
##' A single `./packages.R` file is the default, but you can provide a
##' vector of paths directly, using the R global option `capsule.sources`, or
##' the environment variable `CAPSULE_SOURCES` (the latter takes only a single
##' file name). Using a single file with all library() calls makes an explicit
##' assertion of your dependencies. This way spurious usages of pkg:: for
##' packages not stated as dependencies will cause errors that can be caught.
##'
##' @title capsule_sources
##' @param paths The default files in which to look for dependencies
##' @author Noam Ross
##' @export
capsule_sources <- function(paths = "./packages.R") {
  getOption(
    "capsule.sources",
     default = Sys.getenv("CAPSULE_SOURCES", unset = paths)
  )
}
