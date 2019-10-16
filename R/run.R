run_callr <- function(func, ...) {

  callr::r(func = func,
           libpath = c(renv::paths$library(), system_libraries()),
           ...)

}

run <- function(code) {

  withr::with_libpaths(new = renv::paths$library(),
                       code = code)

}
