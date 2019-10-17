run_callr <- function(func, ...) {

  reproduce_lib_if_not_present()
  callr::r(func = func,
           libpath = c(renv::paths$library(), system_libraries()),
           ...)

}

run <- function(code) {

  reproduce_lib_if_not_present()
  withr::with_libpaths(new = renv::paths$library(),
                       code = code)

}


reproduce_lib_if_not_present <- function() {

  if(!dir.exists(renv::paths$library())) reproduce_lib()

}
