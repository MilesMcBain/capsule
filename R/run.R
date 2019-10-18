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
##'
##' @title run_callr
##' @param func a function to run in the capsule context
##' @param ... additional arguments passed to `callr::r()`
##' @return output of `func`
##' @author Miles McBain
##' @seealso [callr::r()] for detailed calling semantics, [create()] to make the
##'   lockfile. [run()] for a lighter weight alternative.
##' @export
##' @examples
##' run_callr(function() {library()})
##' /dontrun{
##' run_callr(function() rmarkdown::render("./analysis.Rmd"))
##' }
run_callr <- function(func, ...) {

  reproduce_lib_if_not_present()
  callr::r(func = func,
           libpath = c(renv::paths$library()),
           ...)

}
##' run code in the context of the capsule
##' 
##' Execute the supplied function in the context of the capsule library, by
##' changing the R library paths it searches.
##'
##' For code that creates its own process like
##' `drake::r_make()`this is safe, but be wary using it
##' on arbitrary code as the global package environment can be irreversibly
##' contaminated due to code that has run earlier in the session. Use
##' [run_callr()] if in doubt.
##'
##' Note: `rmarkdown::render()` and `knitr::knit()` do not create new processes
##' and so should be called with run_callr()
##'
##' @inheritSection run_callr Lockfile
##'
##' @title run
##' @param code an expression to run in the context of the capsule library.
##' @return output of `code`
##' @author Miles McBain
##' @seealso [create()] to make the lockfile. [run_callr()] for a safer version.
##' @export
##' @examples
##' run(library())
##' run(search())
run <- function(code) {

  reproduce_lib_if_not_present()
  withr::with_libpaths(new = renv::paths$library(),
                       code = code)

}

reproduce_lib_if_not_present <- function() {

  if(!dir.exists(renv::paths$library())) reproduce_lib()

}
