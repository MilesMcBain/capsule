reproduce_lib <- function() {

  callr::r(function(){
    renv::init(bare = TRUE)
    renv::deactivate()
  })
  renv::restore(project = getwd(),
                library = renv::paths$library(),
                confirm = FALSE)

}


