test_that("getting_local_deps works", {

  local_lib <- tempdir()

  withr::with_libpaths(local_lib, {
    install.packages()
  })

})


test_that("lockfile and dep file comparison works", {

  up_to_date_lockfile <- test_path("test_files/up_to_date_renv.lock")
  depfile <- test_path("test_files/packages.R")

  depfile_deps <- detect_dependencies(depfile)

  expect_snapshot_value(depfile_deps, style = "json2")

  lock_file_deps <- get_lockfile_deps(depfile_deps, lockfile)

  expect_snapshot_value(lock_file_deps, style = "json2")

  get_pkg_behind_capsule(depfile, lockfile)

  any_pkg_behind_capsule(dep_source_paths, lockfile_path)


 })

