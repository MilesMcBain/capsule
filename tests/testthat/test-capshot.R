test_that("test capshot", {
  capshot(
    testthat::test_path("datapasta.R"),
    testthat::test_path("capsule.lock")
  )
  renv::snapshot(
    testthat::test_path("datapasta.R"),
    lockfile = testthat::test_path("renv.lock"),
    packages = names(
        detect_dependencies(testthat::test_path("datapasta.R"))),
        prompt = FALSE
  )
  capsule_json <- jsonlite::fromJSON(testthat::test_path("capsule.lock"))
  renv_json <- jsonlite::fromJSON(testthat::test_path("renv.lock"))

  # renv adds itself to the lockfile. Capsule doesn't need to do that.
  renv_json$Packages$renv <- NULL

  # need to put packages in same order
  capsule_json$Packages <- sort_by_name(capsule_json$Packages)
  renv_json$Packages <- sort_by_name(capsule_json$Packages)

  # Need to handle the different takes on repositories here.

  testthat::expect_mapequal(
    capsule_json,
    renv_json 
  )
  
  
})