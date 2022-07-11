test_that("lockfile/library comparisons work", {


  temp_dir <- tempdir()
  working_dir_path <- file.path(temp_dir, "compare")
  dir.create(working_dir_path)
  withr::defer(unlink(working_dir_path, recursive = TRUE), teardown_env())

  file.copy(test_path("renv_cran.lock"), working_dir_path)
  file.copy(test_path("renv_github_cran_ver.lock"), working_dir_path)
  file.copy(test_path("renv_pak_rspm.lock"), working_dir_path)

  withr::with_dir(
    working_dir_path,
    {
      # setup a fake R library
      renv::restore(
        project = getwd(),
        library = renv::paths$library(),
        lockfile = "renv_cran.lock",
        confirm = FALSE,
        repos = c(CRAN = "https://cran.rstudio.com")
      )

      withr::with_libpaths(
        renv::paths$library(),
        action = "prefix",
        code = {
          # local library and lockfile match
          expect_snapshot(compare_capsule_to_lockfile("renv_cran.lock"))
          expect_false(any_local_behind_lockfile("renv_cran.lock"))
          expect_null(whinge(lockfile_path = "renv_cran.lock"))


          # local has CRAN, lockfile has GitHub with same version
          result <- NULL
          expect_warning(
            result <- any_local_behind_lockfile("renv_github_cran_ver.lock"),
            "Packages have equal versions but different remote SHAs: renv"
          )
          expect_false(result)
          expect_warning(
            whinge(lockfile_path = "renv_github_cran_ver.lock"),
            "Packages have equal versions but different remote SHAs: renv"
          )

          # local has CRAN, lockfile has pak-installed RSPM
          expect_snapshot(compare_capsule_to_lockfile("renv_pak_rspm.lock"))
          expect_false(any_local_behind_lockfile("renv_pak_rspm.lock"))
          expect_null(whinge(lockfile_path = "renv_pak_rspm.lock"))
        }
      )
      delete_local_lib()
    }
  )


})
