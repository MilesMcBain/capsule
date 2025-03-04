temp_dir_root <- tempdir()
temp_lib_path <- file.path(temp_dir_root, "capsule_lib")

# create test library
dir.create(temp_lib_path)

get_test_libpaths <- function() {
  c(
    temp_lib_path,
    .libPaths()
  )
}

# Set CRAN
old_repos <- getOption("repos")
options(repos = c(CRAN = "https://cloud.r-project.org"))
withr::defer(options(repos = old_repos), teardown_env())
cleanup <- function() {
  unlink(temp_lib_path, recursive = TRUE)
}
# burn it all down
withr::defer(cleanup(), teardown_env())

# populate test library
withr::with_libpaths(
  new = temp_lib_path,
  code = {
    withr::with_options(
      list(
        repos = c(mm = "https://milesmcbain.r-universe.dev", CRAN = "https://cloud.r-project.org/")
      ),
      # ideally would use pak here so package cache gets used on test runs
      # but pack can't install using a library it itself it not in.
      # TODO Could we create a lockfile to restore to the temp library?
      renv::restore(
        lockfile = testthat::test_path("testrpkg.lock"),
        library = temp_lib_path,
        confirm = FALSE
      )
    )
  }
)

