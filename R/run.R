##' run function in a new process in the capsule
##'
##' Execute the supplied function in the context of the capsule library using
##' `callr::r`. This ensures code is run in a new R process that will not be
##' contaminated by the state of the interactive development environment.
##'
##' @section Lockfile:
##' At a minimum, an `renv` lockfile must be present in the current working
##'   directory. The capsule library will be generated from the lockfile if it
##'   does not exist. Use `create()` to make the lockfile.
##'
##' @section Details:
##' `run` is a more convenient interface to `run_callr`, which inserts the
##' `code` argument into
##' the body of a function, to be run in a child R process. The code is passed
##' through to the function body using non-standard evaluation. If edge cases
##' arise due to non-standard evaluation, prefer `run_callr`.
##'
##' @rdname run
##' @title run functions in the capsule
##' @param func a function to run in the capsule context, as per the
##'  [callr::r()] interface.
##' @param code the body of function to be run in the
##'   capsule context. See Details.
##' @param ... additional arguments passed to `callr::r()`
##' @return output of `func`
##' @author Miles McBain
##' @seealso [callr::r()] for detailed calling semantics, [create()] to make the
##'   lockfile. [run()] for a lighter weight alternative.
##' @export
##' @examples
##' \dontrun{
##' run_callr(function() {library(tidyverse)})
##' run(library(tidyverse))
##' By default rmarkdown::render looks into the .GlobalEnv:
##' run_session(rmarkdown::render("./analysis.Rmd"))
##' }
run_callr <- function(func, show = TRUE, lockfile_path = "./renv.lock", ...) {

  reproduce_lib_if_not_present(lockfile_path)
  callr::r(
    func = func,
    libpath = c(renv::paths$library()),
    show = show,
    ...
  )

}

#' Run an R script in a new process in the capsule
#'
#' Execute the supplied R script in the context of the capsule library using
#' [callr::rscript()]. This ensures the script is executed in a new R process
#' that will not be contaminated by the state of the interactive development
#' environment and will use the R packages and versions in the capsule.
#'
#' @seealso [run_callr()] for more details relevant to `run_rscript()`,
#'   [callr::r()] for detailed calling semantics, [create()] to make the
#'   lockfile. [run()] for a lighter weight alternative.
#'
#' @param path The path to the R script
#' @inheritParams callr::rscript
#' @inheritDotParams callr::rscript
#'
#' @return Invisibly returns the result of [callr::rscript()]
#'
#' @export
run_rscript <- function(path, ..., show = TRUE) {
  reproduce_lib_if_not_present()
  callr::rscript(
    path,
    libpath = c(renv::paths$library()),
    show = show,
    ...
  )
}


#' @rdname run
#' @export
run <- function(code) {

  arg <- substitute(code)
  run_fn <- bquote(function() {
    .(arg)
  })
  run_callr(eval(run_fn))

}

##' run code in the context of the capsule in the current R session
##'
##' Execute the supplied function in the context of the capsule library, by
##' changing the R library paths it searches.
##'
##' In almost all cases, run or run_callr which do effectively the same thing,
##' are preferred. This is because the `code` argument can cause packages
##' to be attached, and thus not read from the capsule library.
##'
##' For example if `code` was `drake::r_make()` this would cause `drake`, to
##  be attached from the main R library, not the capsule, which could cause
##' compatibility issues.
##'
##' Use this function when you have R code that modifies the .GlobalEnv, and
##' you want to inspect it at the end, or you want to actively debug with #'
##' browser() or recover(). Even then it may be preferrable to use
##' capsule::repl() to do debugging.
##'
##' @inheritSection run_callr Lockfile
##'
##' @title run_session
##' @param code an expression to run in the context of the capsule library.
##' @return output of `code`
##' @author Miles McBain
##' @seealso [create()] to make the lockfile. [run_callr()] and [run()] for safer versions.
##' @export
##' @examples
##' \dontrun{
##' run(library())
##' run(search())
##'  capsule::run({
##'    search()
##'    message("hello")
##'  })
##' }
run_session <- function(code) {

  reproduce_lib_if_not_present()
  withr::with_libpaths(
    new = renv::paths$library(),
    code = code
  )

}

reproduce_lib_if_not_present <- function(lockfile_path) {

  if (!dir.exists(locate_capsule())) reproduce_lib(lockfile_path)

}
