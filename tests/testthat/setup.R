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

# populate test library
withr::with_libpaths(
  new = temp_lib_path,
  code = install.packages(
    "testrpkg",
    repos = c(mm = "https://milesmcbain.r-universe.dev", CRAN = "https://cloud.r-project.org/"),
    lib = temp_lib_path
  )
)

cleanup <- function() {
  unlink(temp_lib_path, recursive = TRUE)
}

# burn it all down
withr::defer(cleanup(), teardown_env())
