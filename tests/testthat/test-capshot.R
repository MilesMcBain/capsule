# test utils
sort_by_name <- function(named) {
  named[sort(names(named))]
}

differences_in <- function(a, b, diffs) {
  length(setdiff(setdiff(a, b), diffs)) == 0
}

test_that("test capshot", {

  capsule_lock <- tempfile(fileext = ".lock")
  renv_lock <- tempfile(fileext = ".lock")

  capshot(
    testthat::test_path("datapasta.R"),
    capsule_lock
  )
  renv::snapshot(
    testthat::test_path("datapasta.R"),
    lockfile = renv_lock,
    packages = names(
      detect_dependencies(testthat::test_path("datapasta.R"))
    ),
    prompt = FALSE
  )
  capsule_json <- jsonlite::fromJSON(capsule_lock)
  renv_json <- jsonlite::fromJSON(renv_lock)

  # renv adds itself to the lockfile. Capsule doesn't need to do that.
  renv_json$Packages$renv <- NULL

  # need to put packages in same order
  capsule_json$Packages <- sort_by_name(capsule_json$Packages)
  renv_json$Packages <- sort_by_name(capsule_json$Packages)

  # again ignoring renv in the lock, are the packages the same
  expect_equal(
    setdiff(names(renv_json$Packages), "renv"),
    names(capsule_json$Packages)
  )

  comparison_packages <- names(capsule_json$Packages)

  # Does the data for each package have the same values.
  # Order doesn't matter.
  package_data_similar <-
    lapply(comparison_packages, function(package_name) {
      capsule_package_data <- capsule_json$Packages[[package_name]]
      renv_package_data <- renv_json$Packages[[package_name]]

      capsule_package_data_names <- names(
        capsule_package_data
      )

      differences_in(
        names(renv_package_data),
        names(capsule_package_data),
        c("Hash", "Requirements")
      ) &&
        all(
          unlist(capsule_package_data[capsule_package_data_names]) ==
            unlist(renv_package_data[capsule_package_data_names])
        )
    })

  expect_true(all(unlist(package_data_similar)))
  unlink(capsule_lock)
  unlink(renv_lock)
})
