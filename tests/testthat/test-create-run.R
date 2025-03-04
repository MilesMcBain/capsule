test_that("create and run works", {

  withr::with_libpaths(
    new = get_test_libpaths(),
    code = {
      temp_dir <- tempdir()
      working_dir_path <- file.path(temp_dir, "capsule")

      dir.create(working_dir_path)
      withr::defer(unlink(working_dir_path, recursive = TRUE), teardown_env())
      file.copy(
        testthat::test_path("__testrpkg.R"),
        file.path(working_dir_path, "__testrpkg.R")
      )

      # create a capsule library
      withr::with_dir(
        working_dir_path,
        capsule::create(
          dep_source_paths = "__testrpkg.R"
        )
      )

      expect_true(
        file.exists(
          file.path(working_dir_path, "renv.lock")
        )
      )

      lib_name <-
        list.files(
          file.path(working_dir_path, "renv", "library"),
          pattern = "^.renv",
          recursive = TRUE,
          include.dirs = TRUE,
          all.files = TRUE,
          full.names = TRUE
        ) %>%
      fs::path_split() %>%
      unlist() %>%
      head(-1) %>% # drop .renv
      fs::path_join() %>%
      as.character()

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

      # now let's check the lib paths using capsule::run()
      capsule_lib_paths <- withr::with_dir(
        working_dir_path,
        capsule::run(.libPaths())
      )

      # The priority library is the same
      expect_equal(
        capsule_lib_paths[[1]],
        lib_name
      )
    }
  )

})
