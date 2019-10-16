run <- function(code) {

  withr::with_libpaths(new = renv::paths$library(),
                       code = code)

}
