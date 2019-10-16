create <- function(dep_source_paths = "./packages.R") {

  callr::r(function(){
    renv::init(bare = TRUE)
    renv::deactivate()
  })

  renv::hydrate(renv::dependencies(dep_source_paths)$Package,
                library = renv::paths$library())

  renv::snapshot(type = "simple",
                 library = c(renv::paths$library(), system_libraries()),
                 confirm = FALSE,
                 force = TRUE)
}
