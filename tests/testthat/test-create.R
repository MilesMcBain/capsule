test_that("create works", {
  temp_dir <- tempdir()
  working_dir_path <- file.path(temp_dir, "capsule")
  dir.create(working_dir_path)
  file.copy(
    testthat::test_path("datapasta.R"),
    file.path(working_dir_path, "datapasta.R")
  )

  # create a capsule library
  withr::with_dir(
    working_dir_path,
    capsule::create(
      dep_source_paths = "datapasta.R"
    )
  )

  expect_true(
    file.exists(
      file.path(working_dir_path, "renv.lock")
    )
  )

  lib_name <- list.files(
    list.files(
      file.path(working_dir_path, "renv", "library"),
      full.names = TRUE
    ),
    full.names = TRUE
  )

  libraries <- list.files(
    lib_name
  )

  lockfile_json <- jsonlite::fromJSON(
    file.path(working_dir_path, "renv.lock")
  )

  # renv installs itself by default, so other than this,
  # there should be no differences
  expect_equal(
    setdiff(
      libraries,
      names(lockfile_json$Packages)
    ),
    "renv"
  )

  # check they all have a DESCRIPTION
  expect_true(
    all(vapply(
      file.path(lib_name, libraries, "DESCRIPTION"),
      file.exists,
      logical(1)
    ))
  )

  unlink(working_dir_path, recursive = TRUE)

})
